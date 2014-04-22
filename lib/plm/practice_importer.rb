module Plm
  class PracticeImporter
    include Common

    def create_practices(parser)
      parser.practice_data.each do |title, content|
        subdepartment = content[:subdepartment]
        parser.subspeciality.disciplines.special_work.find_or_initialize_by_title(:title => title).tap do |practice|
          practice.subdepartment = subdepartment

          practice.competences.clear

          content[:competences].each do |competence|
            practice.competences << parser.subspeciality.competences.find_by_index(competence)
          end

          practice.credit_units = {}
          practice.checks.destroy_all
          practice.loadings.destroy_all
          practice.save(:validate => false)
          content[:semesters].each do |item|
            semester_num = item.delete(:semester)
            practice.credit_units.merge!( semester_num => item.delete(:credit_units) )
            semester = parser.subspeciality.semesters.find_by_number semester_num
            practice.checks.create :semester => semester, :kind => :practice if item.delete(:test)
            item.delete(:total)
            item.each do |k,v|
              next if v.zero?
              practice.loadings.create :semester => semester, :kind => k, :value => v
            end
          end

        end
      end
    end

    private
      def import_actions(parser)
        create_practices(parser)
      end
  end
end
