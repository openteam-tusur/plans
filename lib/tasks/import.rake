# encoding: utf-8

require 'progress_bar'
require 'nokogiri'
require 'timecop'
require 'memoist'
require 'fileutils'

class DisciplineImporter
  attr_accessor :plan_importer, :xml

  delegate :subspeciality, :file_path, :year, :cycle_node, :subspeciality_postal?, :to => :plan_importer
  delegate :find_subdepartment, :warn, :to => :plan_importer

  def initialize(plan_importer, xml)
    self.plan_importer = plan_importer
    self.xml = xml
  end

  def discipline_title
    xml['Дис'].squish
  end

  def discipline_subdepartment
    find_subdepartment(xml['Кафедра']) || subspeciality.subdepartment
  end

  def find_discipline
    subspeciality.disciplines.find_or_initialize_by_title(discipline_title)
  end

  def discipline
    find_discipline.tap do |discipline|
      discipline.subdepartment = discipline_subdepartment
      discipline.cycle = "#{cycle_abbr}. #{cycle_name}"
      discipline.summ_loading = xml['ПодлежитИзучению']
      discipline.summ_srs = xml['СР']
      discipline.cycle_code = cycle_value
      refresh discipline
    end
  end

  def cycle_value
    xml['Цикл']
  end

  def cycle_abbr
    cycle_value.split('.').first
  end

  def cycle_name
    cycle_node(cycle_abbr)['Название'].squish
  rescue
    raise "не могу найти расшифровку цикла '#{cycle_abbr}' для дисциплины '#{discipline_title}'"
  end

  extend Memoist

  memoize :discipline_title, :discipline
  memoize :cycle_abbr, :cycle_value

  def check_abbrs
    Check.enum_values(:check_kind).map do |kind|
      [kind, I18n.t(kind, :scope => 'activerecord.attributes.check.check_kind_abbrs')]
    end
  end

  def loading_abbrs
    Loading.enum_values(:loading_kind).map do |kind|
      [kind, I18n.t(kind, :scope => 'activerecord.attributes.loading.loading_kind_abbrs')]
    end
  end

  def import_check(semester, kind)
    discipline.checks.find_or_initialize_by_semester_id_and_check_kind(semester.id, kind).tap do |check|
      refresh check
      check.save!
    end
  end

  def import_loading(semester, kind, value)
    discipline.loadings.find_or_initialize_by_semester_id_and_loading_kind(semester.id, kind).tap do |loading|
      refresh loading
      loading.value = value
      loading.save!
    end if value
  end

  def import_nonpostal
    check_abbrs.each do |kind, abbr|
      semester_numbers = xml["Сем#{abbr}"]
      next unless semester_numbers
      semester_numbers.gsub(/р/, '').each_char do |semester_number|
        semester = subspeciality.create_or_refresh_semester(semester_number)
        next unless semester
        import_check(semester, kind)
      end
    end
    xml.css('Сем').each do |loading_xml|
      semester = subspeciality.create_or_refresh_semester(loading_xml['Ном'])
      loading_abbrs.each do |kind, abbr|
        import_loading(semester, kind, loading_xml[abbr])
      end
    end
  end

  def import_postal
    xml.css("Курс/Сессия").each do |course_xml|
      course_number = course_xml.parent['Ном'].to_i
      session_number = course_xml['Ном'].to_i
      semester_number = course_number * 2 - 1 # осенний семестр
      case course_number
      when 1
        semester_number += 1 if session_number >= 2
      when 2..5
        semester_number += 1 if session_number >= 3
      when 6
      else raise "unknown course #{course_xml.parent['Ном']}"
      end
      semester = subspeciality.create_or_refresh_semester(semester_number)
      next unless semester
      loading_abbrs.each do |kind, abbr|
        if value = course_xml[abbr]
          existed_value = discipline.loadings.find_by_semester_id_and_loading_kind(semester.id, kind).try(:value)
          import_loading(semester, kind, existed_value.to_i + value.to_i)
        end
      end
      check_abbrs.each do |kind, abbr|
        import_check(semester, kind) if course_xml[abbr]
      end
    end
  end

  def import
    if cycle_value && cycle_abbr.present?
      discipline.save!
      subspeciality_postal? ? import_postal : import_nonpostal
    else
      warn("у дисциплины '#{discipline_title}' не указан цикл")
    end
  end
end

class PlanImporter
  SPECIALITY_CODE = '\d{6}(?:\.(?:62|65|68))?'

  attr_accessor :file_path, :options

  delegate :postal?, :to => :subspeciality, :prefix => true

  def initialize(file_path, options={})
    self.file_path = file_path
    self.options = options
  end

  def import
    Timecop.freeze(time_of_sync) do
      check_year
      if options[:force] || subspeciality.plan_digest != file_path_digest
        really_import
      end
    end
  end

  def cycle_node(cycle_abbr)
    xml.at_css("АтрибутыЦиклов Цикл[Аббревиатура='#{cycle_abbr}']") ||
      xml.at_css("АтрибутыЦиклов Цикл[Абревиатура='#{cycle_abbr}']") # это было бы смешно, если б не было так грустно
  end

  def warn(message)
    log_message = "[WARN] import #{file_path}: #{message}"
    STDERR.puts log_message
    Rails.logger.warn(log_message)
  end

  private

  def xml
    Nokogiri::XML(File.new(file_path))
  end

  def title_node
    xml.css('Титул').first
  end

  def year
    Year.find_by_number file_path.split('/').second
  end

  def year_number
    title_node['ГодНачалаПодготовки']
  end

  def subdepartment_number
    title_node['КодКафедры']
  end

  def find_subdepartment(number)
    year.subdepartments.find_by_number!(number) if number
  end

  def speciality_full_name
    xml.css('Специальность').map{|node| node['Название']}.join(' ').tap do |name|
      name.squish!
      name.gsub! 'заочная с применением дистанционной технологии', 'заочная с дистанционной технологией'
    end
  end

  def speciality_code
    File.basename(file_path).match(/^(\d{6})(?:\d{2})?_(62|65|68)/) do
      "#{$1}.#{$2}"
    end
  end

  def speciality
    year.specialities.find_by_code!(speciality_code) do |speciality|
      speciality.update_attribute :gos_generation, title_node['ТипГОСа'] || 2
    end
  end

  def subspeciality_node
    case speciality.degree
    when 'bachelor'
      xml.at_css('Специальность[Название^="профиль"]')
    when 'magistracy'
      xml.at_css('Специальность[Название^="магистерская программа"]') ||
        xml.at_css('Специальность[Название^="Магистерская программа"]')
    when 'specialty'
      xml.at_css('Специальность[Название^="Специализация"]')
    end
  end

  def subspeciality_title
    if subspeciality_node
      subspeciality_node['Название'].match(/"(.*?)"/).try(:[], 1) ||
        subspeciality_node['Название'].match(/Специализация - (.*)/)[1]
    else
      default_subspeciality_title
    end
  end

  def education_form
    Subspeciality.human_enum_values(:education_form).invert["#{human_education_form} форма"]
  end

  def reduced
    case speciality_full_name
    when /на базе (([а-я]+ )*(ВПО|высшего( [а-я]+)* образования)( [а-я]+)*)/
      $1 =~ /\bпрофил/ ? :higher_specialized : :higher_unspecialized
    when /на базе (([а-я]+ )*(СПО|CПО|среднего( [а-я]+)* образования)( [а-я]+)*)/ # СПО бывает первая латинская
      $1 =~ /\bпрофил/ ? :secondary_specialized : :secondary_unspecialized
    when /на базе (.*)$/
      raise "невозможно вычислить тип сокращённой программы для '#{$1}'"
    else nil
    end
  end

  def find_subspeciality
    speciality.subspecialities
      .find_by_title_and_subdepartment_id_and_education_form_and_reduced!(subspeciality_title,
                                                                          find_subdepartment(subdepartment_number),
                                                                          education_form,
                                                                          reduced)
  end

  def subspeciality
    find_subspeciality.tap do |subspeciality|
      if subspeciality.updated_at == time_of_sync
        raise "#{speciality.import_to_s} уже обновлялась"
      else
        subspeciality.update_column :updated_at, time_of_sync
      end
    end
  end

  def file_path_digest
    Digest::SHA256.hexdigest open(file_path).read
  end

  extend Memoist
  memoize :xml, :title_node, :year, :year_number, :speciality_full_name, :speciality_code
  memoize :speciality, :subspeciality_title, :education_form, :reduced, :subspeciality, :file_path_digest
  memoize :find_subdepartment, :subspeciality_node

  def human_education_form
    speciality_full_name.match(/(заочная с дистанционной технологией|очно-заочная|очная|заочная)/).try(:[], 1)  || 'очная'
  end

  def default_subspeciality_title
    case speciality.degree
    when 'bachelor'
      'Без профиля'
    when 'magistracy'
      throw 'у магистров должен быть указан профиль'
    when 'specialty'
      'Без специализации'
    end
  end

  def check_year
    raise "Год не совпадает #{year_number} != #{year.number}" if  year_number != year.number.to_s
  end

  def reset_acuality_of_associations
    %w[disciplines checks loadings semesters].each do |association_name|
      subspeciality.send(association_name).update_all(:deleted_at => time_of_sync)
    end
  end

  def really_import
    reset_acuality_of_associations

    xml.css('СтрокиПлана Строка').each do |discipline_xml|
      DisciplineImporter.new(self, discipline_xml).import
    end
    subspeciality.update_attributes(file_path: file_path, plan_digest: file_path_digest)
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
        PlanImporter.new(file_path).import
      rescue => e
        puts file_path
        puts e.message
        FileUtils.rm file_path
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
task :sync_year, [:year] => :environment do |task, args|
  bar = ProgressBar.new Dir.glob("data/#{args.year}/**/*.{xml,yml}").count
  year = Year.find_or_create_by_number(args.year)
  year.move_descendants_to_trash
  YearImporter.new(year, bar).import
end


desc "Загрузка учебного плана"
task :import_plan, [:path]=> :environment do |task, args|
  PlanImporter.new(args.path, :force => true).import
end
