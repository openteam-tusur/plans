class Department < ActiveRecord::Base
  belongs_to :year
end

class Subdepartment < ActiveRecord::Base
  belongs_to :department
  has_one :year, :through => :department
end

class UnbindYearFromFaculties < ActiveRecord::Migration
  def up
    first_subdepartments.each do |subdepartment|
      similar = similar_subdepartments(subdepartment)
      similar_ids = similar.map(&:id)
      Discipline.where(:subdepartment_id => similar_ids).update_all(:subdepartment_id => subdepartment.id)
      Subspeciality.where(:subdepartment_id => similar_ids).update_all(:subdepartment_id => subdepartment.id)
      similar.map(&:destroy)
    end
    Department.where('year_id <> ?', year_2007).destroy_all
    remove_column :departments, :year_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def year_2007
    Year.find_by_number(2007)
  end

  def first_subdepartments
    subdepartments.select{|s| s.year == year_2007 }
  end

  def subdepartments
    Subdepartment.includes(:year).all
  end

  def similar_subdepartments(subdepartment)
    subdepartments.select{|s| s.abbr == subdepartment.abbr}.tap do |subdepartments|
      subdepartments.delete(subdepartment)
    end
  end

  extend Memoist
  memoize :subdepartments, :similar_subdepartments, :year_2007
end
