# encoding: utf-8

desc "Синхронизация справочников"
task :sync => :environment do
  Dir.glob("data/*").each do |folder|
    year_number = File.basename(folder)
    year = Year.find_or_create_by_number(year_number)
    YAML.load_file("data/#{year.number}/departments.yml").each do |department_attributes|
      department = year.departments.find_or_initialize_by_abbr department_attributes['abbr']
      if (subdepartments_attributes = department_attributes.delete('subdepartments_attributes'))
        department.update_attributes! department_attributes
        subdepartments_attributes.each do |subdepartment_attributes|
          subdepartment = year.subdepartments.find_or_initialize_by_number(subdepartment_attributes['number'])
          subdepartment.attributes = subdepartment_attributes
          subdepartment.department = department
          subdepartment.save!
        end
      end
    end
  end
end
