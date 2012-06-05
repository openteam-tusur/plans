# encoding: utf-8

class YearImporter
  attr_accessor :year, :bar

  def initialize(year, bar)
    self.year, self.bar = year, bar
  end

  def import
    import_departments
    import_specialities
    import_plans
  end

  def import_departments
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
    bar.increment!
  end

  def import_specialities
    YAML.load_file("data/#{year.number}/specialities.yml").each do |degree, specialities_attributes|
      specialities_attributes.each do |speciality_attributes|
        speciality = year.specialities.find_or_initialize_by_code(speciality_attributes['code'])
        subspecialities_attributes = speciality_attributes.delete('subspecialities')
        speciality.update_attributes! speciality_attributes.merge(:degree => degree)
        subspecialities_attributes.each do |subspeciality_attributes|
          subspeciality = speciality.subspecialities.find_or_initialize_by_title(subspeciality_attributes['title'])
          subspeciality.subdepartment = year.subdepartments.find_by_abbr(subspeciality_attributes['subdepartment'])
          subspeciality.save! rescue p subspeciality_attributes['subdepartment']
        end
      end
    end
    bar.increment!
  end

  def import_plans
    Dir.glob("data/#{year.number}/plans/*/*/*.xml") do |file_path|
      xml = Nokogiri::XML(File.new(file_path))
      title_node = xml.css('Титул').first
      year_number = title_node['ГодНачалаПодготовки'].to_i
      raise "Год не совпадает #{year_number} != #{year.number}!!!" if year_number != year.number
      speciality_code = xml.css('Специальность')[0]['Название'].scan(/\d{6}.\d{2}/).first
      speciality = year.specialities.find_by_code(speciality_code)
      subspeciality_title = xml.css('Специальность')[1]['Название'].match(/"(.*)"/)[1].squish
      subspeciality = speciality.subspecialities.find_by_title(subspeciality_title)
      xml.css('СтрокиПлана Строка').each do |discipline_xml|
        discipline = subspeciality.disciplines.find_or_initialize_by_title(discipline_xml['Дис'].squish)
        discipline.subdepartment = year.subdepartments.find_by_number((discipline_xml['Кафедра'] || title_node['КодКафедры']))
        cycle_abbr = discipline_xml['Цикл'].split('.').first
        cycle = xml.css("АтрибутыЦиклов Цикл[Аббревиатура=#{cycle_abbr}]", "АтрибутыЦиклов Цикл[Абревиатура=#{cycle_abbr}]")[0]['Название']
        discipline.cycle = "#{cycle_abbr}. #{cycle}"
        discipline.save!
      end
      bar.increment!
    end
  end

end

require 'progress_bar'

desc "Синхронизация справочников"
task :sync => :environment do
  bar = ProgressBar.new Dir.glob("data/**/*.{xml,yml}").count
  Dir.glob("data/*").each do |folder|
    year_number = File.basename(folder)
    year = Year.find_or_create_by_number(year_number)
    YearImporter.new(year, bar).import
  end
end
