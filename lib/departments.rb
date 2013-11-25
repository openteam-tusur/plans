require 'singleton'

class Departments
  include Singleton

  attr_accessor :departments

  def initialize
    @departments = YAML.load_file(Rails.root.join('data/departments.yml'))
  end

  def subdepartment_data(subdepartment)
    department_data = @departments.select { |department_data| department_data['abbr'] == subdepartment.department.abbr }.first

    return {} unless department_data

    subdepartment_data = department_data['subdepartments'].select { |subdepartment_data| subdepartment_data['abbr'] == subdepartment.abbr }.first || {}
    subdepartment_data.delete('abbr')
    subdepartment_data.delete('number')

    subdepartment_data
  end

  def department_data(department)
    department_data = @departments.select { |department_data| department_data['abbr'] == department.abbr }.first || {}
    department_data.delete('subdepartments')

    department_data
  end
end
