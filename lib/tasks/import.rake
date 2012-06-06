# encoding: utf-8

require 'progress_bar'

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
      refresh department
      subdepartments_attributes = department_attributes.delete('subdepartments')
      department.update_attributes! department_attributes
      subdepartments_attributes.each do |subdepartment_attributes|
        subdepartment = year.subdepartments.find_or_initialize_by_number(subdepartment_attributes['number'])
        subdepartment.attributes = subdepartment_attributes
        subdepartment.department = department
        refresh subdepartment
        subdepartment.save!
      end
    end
    bar.increment!
  end

  def import_specialities
    YAML.load_file("data/#{year.number}/specialities.yml").each do |degree, specialities_attributes|
      specialities_attributes.each do |speciality_attributes|
        subspecialities_attributes = speciality_attributes.delete('subspecialities')
        speciality = year.specialities.find_or_initialize_by_code(speciality_attributes['code'])
        refresh speciality
        speciality.update_attributes! speciality_attributes.merge(:degree => degree)
        subspecialities_attributes.each do |subspeciality_attributes|
          subspeciality = speciality.subspecialities.find_or_initialize_by_title(subspeciality_attributes['title'])
          subspeciality.subdepartment = year.subdepartments.find_by_abbr(subspeciality_attributes['subdepartment'])
          refresh subspeciality
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
        refresh discipline
        discipline.save!
      end
      bar.increment!
    end
  end


  def refresh(object)
    object.deleted_at = nil
  end
end

def move_all_to_trash
  begin
    time_of_sync = DateTime.now
    Dir.glob('app/models/**/*.rb') do |model|
      klass = File.basename(model, '.rb').classify.constantize
      klass.update_all(:deleted_at => time_of_sync) if klass.attribute_method?(:deleted_at)
    end
  rescue => e
    p e
  end
end

desc "Синхронизация справочников"
task :sync => :environment do
  bar = ProgressBar.new Dir.glob("data/**/*.{xml,yml}").count
  move_all_to_trash
  Dir.glob("data/*").each do |folder|
    year_number = File.basename(folder)
    year = Year.find_or_initialize_by_number(year_number)
    year.update_attribute :deleted_at, nil
    YearImporter.new(year, bar).import
  end
end
