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

    department_data['subdepartments'].select { |subdepartment_data| subdepartment_data['abbr'] == subdepartment.abbr }.first
  end
end
