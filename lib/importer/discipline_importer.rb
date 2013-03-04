# encoding: utf-8

class DisciplineImporter
  attr_accessor :plan_importer, :xml, :imported

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
    xml['Кафедра'] ? find_subdepartment(xml['Кафедра']) : subspeciality.subdepartment
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

  def xml_with_sessions?
    xml.at_css("Курс/Сессия")
  end

  def imported?
    !!imported
  end

  def postal_semester_number(course_number, session_number)
    raise "empty course_number" unless course_number
    raise "empty session_number" unless session_number
    session_number = session_number.to_i
    semester_number = course_number.to_i * 2 - 1 # осенний семестр
    case course_number.to_i
    when 1
      semester_number += 1 if session_number >= 2
    when 2..5
      semester_number += 1 if session_number >= 3
    when 6
    else raise "unknown course #{course_number}"
    end
    semester_number
  end
  extend Memoist

  memoize :discipline_title, :discipline
  memoize :cycle_abbr, :cycle_value, :postal_semester_number

  CHECK_ABBRS = {
    exam:               'Экз',
    end_of_term:        'Зач',
    course_work:        'КР',
    course_projecting:  'КП',
  }

  LOADING_ABBRS = {
    csr:      'КСР',
    exam:     'ЧасЭкз',
    srs:      'СРС',
    lecture:  'Лек',
    lab:      'Лаб',
    practice: 'Пр',
  }

  def create_check(semester, kind)
    discipline.checks.create!(:semester_id => semester.id, :check_kind => kind)
  end

  def create_check(semester_number, kind, value)
    if value
      discipline.checks.create!(:semester_id => find_or_create_semester(semester_number).id, :check_kind => kind)
      self.imported = true
    end
  end

  def create_loading(semester_number, kind, value)
    if value
      semester = find_or_create_semester(semester_number)
      discipline.loadings.find_or_initialize_by_semester_id_and_loading_kind(semester.id, kind) do |loading|
        loading.update_attributes! :value => loading.value.to_i + value.to_i
      end
      self.imported = true
    end
  end

  def import_loadings(loading_xml, semester_number)
    semester = find_or_create_semester(semester_number)
    LOADING_ABBRS.each do |kind, abbr|
      create_loading semester_number, kind, loading_xml[abbr]
    end
  end

  def import_checks(check_xml, semester_number)
    CHECK_ABBRS.each do |kind, abbr|
      create_check(semester_number, kind, check_xml[abbr])
    end
  end

  def import_nonpostal
    xml.css('Сем').each do |semester_xml|
      import_loadings(semester_xml, semester_xml['Ном'])
      import_checks(semester_xml, semester_xml['Ном'])
    end
  end

  def import_postal_from_xml_with_sessions
    xml.css("Курс/Сессия").each do |session_xml|
      import_loadings(session_xml, postal_semester_number(session_xml.parent['Ном'], session_xml['Ном']))
      import_checks(session_xml, postal_semester_number(session_xml.parent['Ном'], session_xml['Ном']))
    end
  end

  def import_postal_from_xml_without_sessions
    xml.css("/Курс").each do |course_xml|
      CHECK_ABBRS.each do |kind, abbr|
        if session = course_xml[abbr]
          create_check postal_semester_number(course_xml['Ном'], session), kind, course_xml[abbr]
        end
      end
      LOADING_ABBRS.each do |kind, abbr|
        if loading = course_xml[abbr]
          loading_value = loading.to_i
          warn("'#{discipline_title}' #{course_xml['Ном']} курс: #{kind}(#{loading_value}) не распределен по семестрам")
          create_loading (course_xml['Ном'].to_i * 2 - 1), kind, (loading_value/2)
          create_loading (course_xml['Ном'].to_i * 2), kind, (loading_value - loading_value/2)
        end
      end
    end
  end

  def import
    if cycle_value && cycle_abbr.present?
      discipline.save!
      if subspeciality_postal?
        import_postal_from_xml_with_sessions
        import_postal_from_xml_without_sessions unless imported?
      else
        import_nonpostal
      end
    else
      warn("у дисциплины '#{discipline_title}' не указан цикл")
    end
  rescue => e
    warn("не могу импорировать дисциплину #{discipline_title}")
    raise e
  end
end

