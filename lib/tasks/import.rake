# encoding: utf-8

require 'progress_bar'
require 'nokogiri'

module PlanImporter

  def self.import_plan_from_file(file_path, year)
    xml = Nokogiri::XML(File.new(file_path))
    title_node = xml.css('Титул').first
    year_number = title_node['ГодНачалаПодготовки'].to_i
    raise "Год не совпадает #{year_number} != #{year.number}!!!" if year_number != year.number
    speciality_full_name = xml.css('Специальность').map{|speciality_node| speciality_node['Название']}.join(' ')
    speciality_code = speciality_full_name.scan(/\d{6}.\d{2}/).first
    speciality = year.specialities.find_by_code(speciality_code)
    speciality.update_attribute :gos_generation, title_node['ТипГОСа'] || 2
    raise "нет специальности с кодом #{speciality_code} в year_number году" unless speciality
    subspeciality_title = speciality_full_name.match(/"(.*)"/) ? speciality_full_name.match(/"(.*)"/)[1].squish : speciality.degree == 'specialty' ? "Без специализации" : "Без профиля"
    subspeciality = speciality.subspecialities.find_by_title(subspeciality_title)
    subspeciality.move_descendants_to_trash
    raise "нет профиля #{subspeciality_title} для специальности #{speciality_code} в #{year_number} года" unless subspeciality
    xml.css('СтрокиПлана Строка').each do |discipline_xml|
      discipline = subspeciality.disciplines.find_or_initialize_by_title(discipline_xml['Дис'].squish)
      discipline.subdepartment = year.subdepartments.find_by_number((discipline_xml['Кафедра'] || title_node['КодКафедры']))
      cycle_value = discipline_xml['Цикл']
      next unless cycle_value
      cycle_abbr, component = cycle_value.split('.')[0..1]
      cycle = xml.css("АтрибутыЦиклов Цикл[Аббревиатура='#{cycle_abbr}']", "АтрибутыЦиклов Цикл[Абревиатура=#{cycle_abbr}]")[0]['Название'].squish
      discipline.cycle = "#{cycle_abbr}. #{cycle}"
      discipline.summ_loading = discipline_xml['ПодлежитИзучению']
      discipline.summ_srs = discipline_xml['СР']
      discipline.cycle_code = discipline_xml['Цикл']
      refresh discipline
      discipline.save!
      Check.enum_values(:check_kind).each do |check_kind|
        kind_abbr = I18n.t check_kind, :scope => "activerecord.attributes.check.check_kind_abbrs"
        semester_numbers = discipline_xml["Сем#{kind_abbr}"]
        next unless semester_numbers
        semester_numbers.each_char do |semester_number|
          semester = subspeciality.create_or_refresh_semester(semester_number)
          next unless semester
          check = discipline.checks.where(:semester_id => semester, :check_kind => check_kind).first || discipline.checks.build(:semester => semester, :check_kind => check_kind)
          refresh check
          check.save
        end
      end
      discipline_xml.css('Сем').each do |loading_xml|
        semester = subspeciality.create_or_refresh_semester(loading_xml['Ном'])
        next unless semester
        Loading.enum_values(:loading_kind).each do |loading_kind|
          kind_abbr = I18n.t loading_kind, :scope => "activerecord.attributes.loading.loading_kind_abbrs"
          value = loading_xml[kind_abbr]
          next unless value
          loading = discipline.loadings.where(:semester_id => semester, :loading_kind => loading_kind).first || discipline.loadings.build(:semester => semester, :loading_kind => loading_kind)
          refresh loading
          loading.value = value
          loading.save
        end
      end
    end
  end

  def self.refresh(object)
    object.deleted_at = nil
  end
end

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
      department.context = Context.find_by_title(department.title)
      refresh department
      subdepartments_attributes = department_attributes.delete('subdepartments')
      department_attributes.delete('chief')
      department.update_attributes! department_attributes
      subdepartments_attributes.each do |subdepartment_attributes|
        subdepartment = year.subdepartments.find_or_initialize_by_number(subdepartment_attributes['number'])
        subdepartment_attributes.delete('chief')
        subdepartment.attributes = subdepartment_attributes
        subdepartment.department = department
        subdepartment.context = Context.find_by_title(subdepartment.title)
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
          subdepartment = year.subdepartments.find_by_abbr(subspeciality_attributes['subdepartment'])
          graduate_subdepartment = year.subdepartments.find_by_abbr(subspeciality_attributes['graduate_subdepartment'] || subspeciality_attributes['subdepartment'])
          subspeciality = speciality.subspecialities.find_or_initialize_by_title_and_subdepartment_id(:title => subspeciality_attributes['title'].squish,
                                                                                                      :subdepartment_id => subdepartment.id)
          subspeciality.graduate_subdepartment = graduate_subdepartment
          refresh subspeciality
          subspeciality.save! rescue p subspeciality_attributes['subdepartment']
        end
      end
    end
    bar.increment!
  end

  def import_plans
    Dir.glob("data/#{year.number}/plans/*/*/*.xml") do |file_path|
      PlanImporter.import_plan_from_file(file_path, year)
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
      klass.update_all(:deleted_at => time_of_sync) if klass.respond_to?(:attribute_method?) && klass.attribute_method?(:deleted_at)
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

desc "Синхронизация года"
task :sync_year => :environment do
  year_number = ENV['year']
  bar = ProgressBar.new Dir.glob("data/#{year_number}/**/*.{xml,yml}").count
  year = Year.find_or_create_by_number(year_number)
  year.move_descendants_to_trash
  YearImporter.new(year, bar).import
end


desc "Загрузка учебного плана"
task :import_plan => :environment do
  year = Year.find_by_number(ENV['FILE_PATH'].match(/\b\d{4}\b/)[0])
  raise "нет такого года" unless year
  PlanImporter.import_plan_from_file(ENV['FILE_PATH'], year)
end
