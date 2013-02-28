# encoding: utf-8

class DisciplineImporter
  attr_accessor :plan_importer, :xml

  delegate :subspeciality, :file_path, :year, :cycle_node, :subspeciality_postal?, :to => :plan_importer
  delegate :find_subdepartment, :find_or_create_semester, :warn, :to => :plan_importer

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

  def create_check(semester, kind)
    discipline.checks.create!(:semester_id => semester.id, :check_kind => kind)
  end

  def import_nonpostal
    check_abbrs.each do |kind, abbr|
      semester_numbers = xml["Сем#{abbr}"]
      next unless semester_numbers
      semester_numbers.gsub(/р/, '').each_char do |semester_number|
        semester = find_or_create_semester(semester_number)
        create_check(semester, kind)
      end
    end
    xml.css('Сем').each do |loading_xml|
      semester = find_or_create_semester(loading_xml['Ном'])
      loading_abbrs.each do |kind, abbr|
        discipline.loadings.create!(:semester_id => semester.id, :loading_kind => kind, :value => loading_xml[abbr]) if loading_xml[abbr]
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
      semester = find_or_create_semester(semester_number)
      loading_abbrs.each do |kind, abbr|
        if value = course_xml[abbr]
          if loading = discipline.loadings.find_by_semester_id_and_loading_kind(semester.id, kind)
            loading.update_attribute :value, loading.value + value.to_i
          else
            discipline.loadings.create!(:semester_id => semester.id, :loading_kind => kind, :value => value)
          end
        end
      end
      check_abbrs.each do |kind, abbr|
        create_check(semester, kind) if course_xml[abbr]
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

