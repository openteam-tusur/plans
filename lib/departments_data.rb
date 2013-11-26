require 'singleton'

class DepartmentsData
  include Singleton

  attr_accessor :departments_data

  def initialize
    @departments_data = YAML.load_file(Rails.root.join('data/departments.yml'))
  end

  def department_data_with_subdepartments(department)
    departments_data.dup.select { |e| e['abbr'] == department.abbr }.first || {}
  end

  def department_data(department)
    data = department_data_with_subdepartments(department)
    data.delete('subdepartments')

    data
  end
end
