module Plm
  class PracticeImporter
    include Common

    def create_practices(parser)
      parser.practice_data.each do |title, content|
        subdepartment = content[:subdepartment]
        cycle         = content[:cycle]
        parser.subspeciality.disciplines.special_work.find_or_initialize_by_title(:title => title).tap do |practice|
          practice.cycle      ||= cycle
          practice.cycle_id   ||= cycle
          practice.cycle_code ||= cycle
          practice.deleted_at = nil
          practice.subdepartment = subdepartment
          practice.kind = :common

          practice.competences.clear

          content[:competences].each do |competence|
            practice.competences << parser.subspeciality.competences.find_by_index(competence)
          end
          
          practice.credit_units = {}
          practice.checks.destroy_all
          practice.loadings.destroy_all
          content[:semesters].each do |item|
            semester_num = item.delete(:semester)
            practice.weeks_count = item.delete(:weeks)
            practice.credit_units.merge!( semester_num.to_s => item.delete(:credit_units) )
            semester = parser.subspeciality.semesters.find_by_number semester_num
            practice.checks.new :semester => semester, :kind => :end_of_term_diff if item.delete(:test)
            item.delete(:total)
            item.each do |k,v|
              next if v.zero?
              practice.loadings.new :semester => semester, :kind => k, :value => v
            end
          end
          practice.save(:validate => false)
        end
      end
    end

    private
      def import_actions(parser)
        create_practices(parser)
      end
  end
end
