require 'singleton'

class DepartmentsData
  include Singleton

  attr_accessor :departments_data

  def initialize
    @departments_data = YAML.load_file(Rails.root.join('data/departments.yml'))
  end

  def department_data_with_subdepartments(department)
    departments_data.dup.select { |e| e['abbr'] == department.abbr }.first.dup || {}
  end

  def department_data(department)
    data = department_data_with_subdepartments(department)
    data.delete('subdepartments')

    data
  end

  def subdepartment_data(subdepartment)
    data = department_data_with_subdepartments(subdepartment.department)['subdepartments'] || []

    data.select { |e| e['abbr'] == subdepartment.abbr }.first
  end
end
