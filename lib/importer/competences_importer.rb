class CompetencesImporter
  class DisciplineNotFoundError < StandardError
    attr_accessor :title

    def initialize(title)
      @title = title
    end

    def message
      "#{self.class.name}: discipline with title #{title} not found"
    end
  end

  class EmptyCompetencesError < StandardError
    attr_accessor :title

    def initialize(title)
      @title = title
    end

    def message
      "#{self.class.name}: empty competences for discipline #{title}"
    end
  end

  class CompetencesParser
    attr_accessor :subspeciality

    def initialize(subspeciality)
      @subspeciality = subspeciality
    end

    def competences_data
      @competences_data ||= Hash[xml_doc.at('Компетенции').children.css('Строка').map { |n| [n['Индекс'], n['Содержание']] }]
    end

    def disciplines_data
      @disciplines_data ||= {}.tap do |disciplines_data|
        xml_doc.at('СтрокиПлана').children.css('Строка').map do |node|
          title, competences = node['Дис'].squish, node['Компетенции']

          raise EmptyCompetencesError, title if competences.blank?

          competences = competences.split(',').map(&:squish)
          speciality = subspeciality.disciplines.find_by_title(title)

          raise DisciplineNotFoundError, title unless speciality

          disciplines_data[speciality] = competences
        end
      end
    end

    private

    def xml_doc
      return @xml_doc if @xml_doc

      file = File.open(Rails.root.join(subspeciality.file_path))
      @xml_doc = Nokogiri::XML(file)
      file.close

      @xml_doc
    end
  end

  attr_accessor :subspecialities, :progress_bar

  def initialize
    @subspecialities = Subspeciality.joins(:speciality).where('specialities.gos_generation = ?', '3').where('file_path IS NOT NULL')
    @progress_bar = ProgressBar.new(@subspecialities.count)
  end

  def import
    safe_import
  end

  def add_competences_to_disciplines(competences_parser)
    competences_parser.disciplines_data.each do |discipline, competence_indexes|
      discipline.competences.clear

      competence_indexes.each do |index|
        competence = competences_parser.subspeciality.competences.find_by_index(index)
        discipline.competences << competence
      end
    end
  end

  private

  def create_competences(competences_parser)
    competences_parser.competences_data.each do |index, content|
      competence = competences_parser.subspeciality.competences.find_or_create_by_index(index)
      competence.update_attribute :content, content
    end
  end

  def safe_import
    subspecialities.each do |subspeciality|
      competences_parser = CompetencesParser.new(subspeciality)

      begin
        create_competences(competences_parser)
        add_competences_to_disciplines(competences_parser)
      rescue StandardError => e
        p e.message
        # Airbrake
      end

      progress_bar.increment!
    end
  end
end
