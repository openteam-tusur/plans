module Plm
  module Common
    extend ActiveSupport::Concern

    included do
      attr_accessor :subspecialities, :progress_bar
    end

    def initialize
      @subspecialities = Subspeciality.joins(:speciality).where('specialities.gos_generation = ?', '3').where('file_path IS NOT NULL')
      @progress_bar = ProgressBar.new(@subspecialities.count)
    end

    def import
      safe_import
    end

    private

    def safe_import
      subspecialities.each do |subspeciality|
        parser = Plm::SpecialityParser.new(subspeciality)

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

    def competences_data
      @competences_data ||= Hash[xml_doc.at('Компетенции').children.css('Строка').map { |n| [n['Индекс'], n['Содержание']] }]
    end

    def discipline_nodes
      @discipline_nodes ||= xml_doc.at('СтрокиПлана').children.css('Строка')
    end

    def disciplines_data
      @disciplines_data ||= {}.tap do |disciplines_data|
        discipline_nodes.map do |node|
          title, competences = node['Дис'].squish, node['Компетенции']

          raise EmptyCompetencesError, title if competences.blank?

          competences = competences.split(',').map(&:squish)
          discipline = subspeciality.disciplines.find_by_title(title)

          raise DisciplineNotFoundError, title unless discipline

          disciplines_data[discipline] = competences
        end
      end
    end

    def credit_units_data
      @credit_units_data ||= {}.tap do |credit_units_data|
        discipline_nodes.map do |discipline_node|
          title, identifier = discipline_node['Дис'].squish, discipline_node['НовИдДисциплины']
          discipline = subspeciality.disciplines.find_by_title(title)

          raise DisciplineNotFoundError, title unless discipline

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
      @xml_doc = Nokogiri::XML(file)
      file.close

      @xml_doc
    end
  end
end
