# encoding: utf-8

class DepartmentsImporter

  def import_departments
    YAML.load_file("data/departments.yml").each do |department_attributes|
      department = Department.find_or_initialize_by_abbr department_attributes['abbr']
      refresh department
      subdepartments_attributes = department_attributes.delete('subdepartments')
      department_attributes.delete('chief')
      department.update_attributes! department_attributes
      subdepartments_attributes.each do |subdepartment_attributes|
        subdepartment = department.subdepartments.find_or_initialize_by_number(subdepartment_attributes['number'])
        subdepartment_attributes.delete('chief')
        subdepartment.attributes = subdepartment_attributes
        subdepartment.department = department
        refresh subdepartment
        subdepartment.save!
      end if subdepartments_attributes
    end
  end

end
