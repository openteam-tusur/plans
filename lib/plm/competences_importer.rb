module Plm
  class CompetencesImporter
    include Common

    private

    def create_competences(parser)
      parser.competences_data.each do |code, content|
        competence = parser.subspeciality.competences.find_or_create_by_index(content.first)
        competence.update_attribute :content, content.last
      end
    end

    def add_competences_to_disciplines(parser)
      parser.disciplines_data.each do |discipline, competence_indexes|
        discipline.competences.clear

        competence_indexes.each do |index|
          competence = parser.subspeciality.competences.find_by_index(index)
          discipline.competences << competence
        end
      end
    end

    private

    def import_actions(parser)
      create_competences(parser)
      add_competences_to_disciplines(parser)
    end
  end
end

