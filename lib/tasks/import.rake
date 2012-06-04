# encoding: utf-8
def import_departments(year)
  YAML.load_file("data/#{year.number}/departments.yml").each do |department_attributes|
    department = year.departments.find_or_initialize_by_abbr department_attributes['abbr']
    if (subdepartments_attributes = department_attributes.delete('subdepartments'))
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

def import_specialities(year)
  YAML.load_file("data/#{year.number}/specialities.yml").each do |degree, specialities_attributes|
    specialities_attributes.each do |speciality_attributes|
      speciality = year.specialities.find_or_initialize_by_code(speciality_attributes['code'])
      subspecialities_attributes = speciality_attributes.delete('subspecialities')
      speciality.update_attributes! speciality_attributes.merge(:degree => degree)
      subspecialities_attributes.each do |subspeciality_attributes|
        subspeciality = speciality.subspecialities.find_or_initialize_by_title(subspeciality_attributes['title'])
        subspeciality.graduator = year.subdepartments.find_by_abbr(subspeciality_attributes['subdepartment']) ||
                                  year.departments.find_by_abbr(subspeciality_attributes['subdepartment'])
        subspeciality.save! rescue p subspeciality_attributes['subdepartment']
      end
    end
  end
end

def import_plans(year)
  Dir.glob("data/#{year.number}/plans/*/*/*.xml") do |file_path|
    xml = Nokogiri::XML(File.new(file_path))
    year_number = xml.css('Титул').first.attributes['ГодНачалаПодготовки'].value.to_i
    raise "Год не совпадает #{year_number} != #{year.number}!!!" if year_number != year.number
    speciality_code = xml.css('Специальность')[0].attributes['Название'].value.scan(/\d{6}.\d{2}/).first
    speciality = year.specialities.find_by_code(speciality_code)
    subspeciality_title = xml.css('Специальность')[1].attributes['Название'].value.match(/"(.*)"/)[1]
    subspeciality = speciality.subspecialities.find_by_title(subspeciality_title)
  end
end

desc "Синхронизация справочников"
task :sync => :environment do
  Dir.glob("data/*").each do |folder|
    year_number = File.basename(folder)
    year = Year.find_or_create_by_number(year_number)
    import_departments(year)
    import_specialities(year)
    import_plans(year)
  end
end
