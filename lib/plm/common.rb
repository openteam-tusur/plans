module Plm
  module Common
    extend ActiveSupport::Concern

    included do
      attr_accessor :subspecialities, :progress_bar
    end

    def initialize
      @subspecialities = Subspeciality.joins(:speciality).where('specialities.gos_generation = ?', '3').where('file_path IS NOT NULL').readonly(false)
      @progress_bar = ProgressBar.new(@subspecialities.count)
    end

    def import
      safe_import
    end

    private

    def update_approved_on_for(subspeciality, parser)
      subspeciality.update_attribute :approved_on, parser.approved_on
    end

    def safe_import
      subspecialities.each do |subspeciality|

        parser = Plm::SpecialityParser.new(subspeciality)

        update_approved_on_for(subspeciality, parser)

        begin
          import_actions(parser)
        rescue StandardError => e
          p e.message
          Airbrake.notify(e)
        end

        progress_bar.increment!
      end
    end
  end

  class SpecialityParser
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

    attr_accessor :subspeciality

    def initialize(subspeciality)
      @subspeciality = subspeciality
    end

    def approved_on
      xml_doc.at('Титул')['ДатаГОСа']
    end

    def competences_data
      @competences_data ||= Hash[xml_doc.at('Компетенции').children.css('Строка').map { |n| [n['Код'], [n['Индекс'], n['Содержание']]] }]
    end

    def discipline_nodes
      @discipline_nodes ||= xml_doc.at('СтрокиПлана').children.css('Строка')
    end

    def practice_nodes
      @practice_nodes ||= xml_doc.at('СпецВидыРаботНов').children
    end

    def cycle_nodes
      @cycle_nodes ||= xml_doc.at('АтрибутыЦикловНов').children
    end

    def disciplines_data
      @disciplines_data ||= {}.tap do |disciplines_data|
        discipline_nodes.map do |node|
          title, competences = node['Дис'].squish, node['Компетенции']

          if competences.blank?
            p EmptyCompetencesError.new(title).message
            next
          end

          competences = competences.split(',').map(&:squish)
          discipline = subspeciality.disciplines.find_by_title(title)

          unless discipline
            p DisciplineNotFoundError.new(title).message
            next
          end

          disciplines_data[discipline] = competences
        end
      end
    end

    def practice_data
      @practice_data ||= {}.tap do |practice_data|
        practice_nodes.css('ПрочиеПрактики > ПрочаяПрактика, УчебПрактики > ПрочаяПрактика, НИР > ПрочаяПрактика').each do |node|
          subdepartment = nil
          competence_indexes = []
          node['Компетенции'].try(:split, '&').to_a.each do |competence|
            competence_indexes << competences_data[competence].first
          end
          semesters = []
          node.children.css('Семестр').each do |semester|
            if subdepartment.nil?
              subdepartment_node = semester.children.css('Кафедра').try :first
              subdepartment ||= Subdepartment.find_by_number(subdepartment_node['Код']) if subdepartment_node
            end
            semesters << { :semester     => semester['Ном'].to_i,
                           :credit_units => semester['ПланЗЕТ'].to_i,
                           :test         => semester['ЗачО'] == '1',
                           :total        => semester['ПланЧасов'].to_i,
                           :lecture      => semester['ПланЧасовАуд'].to_i,
                           :srs          => semester['ПланЧасовСРС'].to_i,
                           :weeks        => semester['ПланНед'].to_i }
          end
          practice_data.merge! node['Наименование'] => {
            :cycle         => cycle_nodes.search('Цикл[Название*=Практик]').first['Аббревиатура'],
            :subdepartment => subdepartment,
            :competences   => competence_indexes,
            :semesters     => semesters
          }
        end
      end
    end

    def credit_units_data
      @credit_units_data ||= {}.tap do |credit_units_data|
        discipline_nodes.map do |discipline_node|
          title, identifier = discipline_node['Дис'].squish, discipline_node['НовИдДисциплины']
          discipline = subspeciality.disciplines.find_by_title(title)

          unless discipline
            p DisciplineNotFoundError.new(title).message
            next
          end

          credit_units_data[discipline] = { :identifier => identifier, :credit_units => {} }

          discipline_node.children.css('Сем').map do |credit_unit_node|
            semester, credit_units = credit_unit_node['Ном'], credit_unit_node['ЗЕТ']

            credit_units_data[discipline][:credit_units][semester] = credit_units
          end
        end
      end
    end

    private

    def xml_doc
      return @xml_doc if @xml_doc

      file = File.open(Rails.root.join(subspeciality.file_path))
      @xml_doc = Nokogiri::XML(file) do |config|
        config.noblanks
      end
      file.close

      @xml_doc
    end
  end
end
