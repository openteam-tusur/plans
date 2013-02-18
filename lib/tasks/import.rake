# encoding: utf-8

require 'progress_bar'
require 'nokogiri'

module PlanImporter

  def self.import_plan_from_file(file_path, year)
    xml = Nokogiri::XML(File.new(file_path))
    title_node = xml.css('Титул').first
    year_number = title_node['ГодНачалаПодготовки'].to_i
    if year_number != year.number
      p file_path
      raise "Год не совпадает #{year_number} != #{year.number}!!!"
    end
    speciality_full_name = xml.css('Специальность').map{|speciality_node| speciality_node['Название']}.join(' ')
    speciality_code = speciality_full_name.scan(/\d{6}(?:.\d{2})?/).first
    speciality = year.specialities.find_by_code(speciality_code)
    raise "нет специальности с кодом #{speciality_code} в #{year_number} году #{file_path}" unless speciality
    speciality.update_attribute :gos_generation, title_node['ТипГОСа'] || 2
    subspeciality_title = speciality_full_name.match(/"(.*)"/) ? speciality_full_name.match(/"(.*)"/)[1].squish : speciality.degree == 'specialty' ? "Без специализации" : "Без профиля"
    education_form = speciality_full_name.match(/(заочная с дистанционной технологией|очно-заочная|очная|заочная)/).try(:[], 1)  || 'очная'
    education_form = Subspeciality.human_enum_values(:education_form).invert["#{education_form} форма"]
    reduced = case speciality_full_name
              when /на базе (([а-я]+ )*(ВПО|высшего( [а-я]+)* образования)( [а-я]+)*)/
                $1 =~ / профил/ ? :higher_specialized : :higher_unspecialized
              when /на базе (([а-я]+ )*(СПО|CПО|среднего( [а-я]+)* образования)( [а-я]+)*)/ # СПО бывает первая латинская
                $1 =~ / профил/ ? :secondary_specialized : :secondary_unspecialized
              when /на базе (.*)$/
                raise "невозможно вычислить тип сокращённой программы для '#{$1}'"
              else nil
              end
    subspeciality = speciality.subspecialities.find_by_title_and_education_form_and_reduced(subspeciality_title, education_form, reduced)
    raise "нет профиля #{subspeciality_title} для #{education_form} для специальности #{speciality_code} #{reduced_text} в #{year_number} года #{file_path}" unless subspeciality
    plan_digest = Digest::SHA1.hexdigest open(file_path).read
    return if plan_digest.eql?(subspeciality.plan_digest)
    %w[disciplines checks loadings semesters].each do |association_name|
      subspeciality.send(association_name).update_all(:deleted_at => time_of_sync)
    end
    xml.css('СтрокиПлана Строка').each do |discipline_xml|
      discipline = subspeciality.disciplines.find_or_initialize_by_title(discipline_xml['Дис'].squish)
      discipline.subdepartment = year.subdepartments.find_by_number((discipline_xml['Кафедра'] || title_node['КодКафедры']))
      cycle_value = discipline_xml['Цикл']
      next unless cycle_value
      cycle_abbr, component = cycle_value.split('.')[0..1]
      begin
        cycle = xml.css("АтрибутыЦиклов Цикл").select{|c| cycle_abbr == (c['Аббревиатура'] || c['Абревиатура']) }.first['Название'].squish
      rescue => e
        raise "не указан цикл для дисциплины '#{discipline.title}'"
      end
      discipline.cycle = "#{cycle_abbr}. #{cycle}"
      discipline.summ_loading = discipline_xml['ПодлежитИзучению']
      discipline.summ_srs = discipline_xml['СР']
      discipline.cycle_code = discipline_xml['Цикл']
      refresh discipline
      begin
        discipline.save!
      rescue => e
        p discipline.errors
        raise "не удалось сохранить дисциплину '#{discipline.title}'"
      end
      if file_path !~ /plz\.xml/ # очная, очно-заочная
        Check.enum_values(:check_kind).each do |check_kind|
          kind_abbr = I18n.t check_kind, :scope => "activerecord.attributes.check.check_kind_abbrs"
          semester_numbers = discipline_xml["Сем#{kind_abbr}"]
          next unless semester_numbers
          semester_numbers.gsub(/р/, '').each_char do |semester_number|
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
      else # заочная
        discipline_xml.css("Курс/Сессия").each do |loading_xml|
          course_number = loading_xml.parent['Ном'].to_i
          session_number = loading_xml['Ном'].to_i
          semester_number = course_number * 2 - 1 # осенний семестр
          case course_number
          when 1
            semester_number += 1 if session_number >= 2
          when 2..5
            semester_number += 1 if session_number >= 3
          when 6
          else raise "unknown course #{loading_xml.parent['Ном']}"
          end
          semester = subspeciality.create_or_refresh_semester(semester_number)
          next unless semester
          Loading.enum_values(:loading_kind).each do |loading_kind|
            kind_abbr = I18n.t loading_kind, :scope => "activerecord.attributes.loading.loading_kind_abbrs"
            value = loading_xml[kind_abbr]
            next unless value
            loading = discipline.loadings.where(:semester_id => semester, :loading_kind => loading_kind).first || discipline.loadings.build(:semester => semester, :loading_kind => loading_kind)
            refresh loading
            loading.value = loading.value.to_i + value.to_i
            loading.save
          end
          Check.enum_values(:check_kind).each do |check_kind|
            kind_abbr = I18n.t check_kind, :scope => "activerecord.attributes.check.check_kind_abbrs"
            if loading_xml[kind_abbr]
              check = discipline.checks.where(:semester_id => semester, :check_kind => check_kind).first || discipline.checks.build(:semester => semester, :check_kind => check_kind)
              refresh check
              check.save
            end
          end
        end
      end
    end
    subspeciality.update_attributes(file_path: file_path, plan_digest: plan_digest)
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
      end if subdepartments_attributes
    end
    bar.increment!
  end

  def import_specialities
    YAML.load_file("data/#{year.number}/specialities.yml").each do |degree, specialities_attributes|
      next unless specialities_attributes
      specialities_attributes.each do |speciality_attributes|
        subspecialities_attributes = speciality_attributes.delete('subspecialities')
        speciality = year.specialities.find_or_initialize_by_code(speciality_attributes['code'])
        speciality.gos_generation ||= (year.number >= 2011 ? 3 : 2)
        refresh speciality
        speciality.update_attributes! speciality_attributes.merge(:degree => degree)
        subspecialities_attributes.each do |subspeciality_attributes|
          subdepartment = year.subdepartments.find_by_abbr(subspeciality_attributes['subdepartment'])
          raise "Нет кафедры #{subspeciality_attributes['subdepartment']}" unless subdepartment
          graduated_subdepartment = year.subdepartments.find_by_abbr(subspeciality_attributes['graduated_subdepartment'] || subspeciality_attributes['subdepartment'])
          department = year.departments.find_by_abbr(subspeciality_attributes['department']) || subdepartment.department
          subspeciality = speciality.subspecialities.find_or_initialize_by_title_and_subdepartment_id_and_education_form_and_reduced(
            :title            => subspeciality_attributes['title'].squish,
            :subdepartment_id => subdepartment.id,
            :education_form   => subspeciality_attributes['education_form'] || 'full-time',
            :reduced          => subspeciality_attributes['reduced']
          )
          subspeciality.graduated_subdepartment = graduated_subdepartment
          subspeciality.department = department
          refresh subspeciality
          subspeciality.save! #rescue p subspeciality_attributes['subdepartment']
        end
      end
    end
    bar.increment!
  end

  def import_plans
    Dir.glob("data/#{year.number}/plans/*.xml") do |file_path|
      begin
        PlanImporter.import_plan_from_file(file_path, year)
      rescue => e
        puts file_path
        p e.message
        exit
      end
      bar.increment!
    end
  end
end

def refresh(object)
  object.deleted_at = nil
end

def time_of_sync
  @time_of_sync ||= DateTime.now
end

def move_to_trash(model_name)
  klass = model_name.classify.constantize
  klass.update_all(:deleted_at => time_of_sync)
end

def move_all_to_trash
  %w[department speciality subdepartment subspeciality year].each do |model_name|
    move_to_trash(model_name)
  end
end

desc "Форсировать полный повторный импорт"
task :force_sync => :environment do
  %w[department speciality subdepartment subspeciality year discipline check loading semester].each do |model_name|
    move_to_trash(model_name)
  end
  Subspeciality.update_all :plan_digest => nil
end

desc "Синхронизация справочников"
task :sync => :environment do
  bar = ProgressBar.new Dir.glob("data/**/*.{xml,yml}").count
  move_all_to_trash
  Dir.glob("data/*").sort.each do |folder|
    year_number = File.basename(folder)
    year = Year.find_or_initialize_by_number(year_number)
    refresh year
    year.save!
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
