# encoding: utf-8

class DisciplineXML
  attr_accessor :xml, :plan_importer
  attr_accessor :loadings, :checks

  delegate :cycle_node, :warn, :to => :plan_importer

  def initialize(xml, plan_importer)
    self.xml = xml
    self.plan_importer = plan_importer
    self.loadings = {}
    self.checks = {}
  end

  def title
    xml['Дис'].squish
  end

  def subdepartment_number
    xml['Кафедра']
  end

  def summ_loading
    xml['ПодлежитИзучению']
  end

  def summ_srs
    xml['СР']
  end

  def cycle_code
    xml['Цикл']
  end

  def cycle_id
    xml['ИдетификаторДисциплины']
  end

  def cycle_name
    cycle_node(cycle_abbr)['Название'].squish
  rescue
    raise "не могу найти расшифровку цикла '#{cycle_abbr}' для дисциплины '#{discipline_xml.title}'"
  end

  def cycle
    "#{cycle_abbr}. #{cycle_name}"
  end

  def cycle_abbr
    cycle_code.split('.').first
  end

  def valid?
    cycle_code && cycle_abbr.present?
  end

  def parse
    unless @parsed
      xml.at_css('>Сем') ? parse_nonpostal : parse_postal
      @parsed = true
    end
  end

  private

  LOADING_ABBRS = {
    csr:                'КСР',
    exam:               'ЧасЭкз',
    srs:                'СРС',
    lecture:            'Лек',
    lab:                'Лаб',
    practice:           'Пр',
  }

  CHECK_ABBRS = {
    exam:               'Экз',
    end_of_term:        'Зач',
    course_work:        'КР',
    course_projecting:  'КП',
  }

  # course => { session => semester }
  POSTAL_SEMESTER_NUMBER = {
    '1' =>      { '1' => 1,   '2' => 2,   '3' => 2  },
    '2' =>      { '1' => 3,   '2' => 3,   '3' => 4  },
    '3' =>      { '1' => 5,   '2' => 5,   '3' => 6  },
    '4' =>      { '1' => 7,   '2' => 7,   '3' => 8  },
    '5' =>      { '1' => 9,   '2' => 9,   '3' => 10 },
    '6' =>      { '1' => 11,  '2' => 11,  '3' => 11 },
  }

  def loading(semester)
    loadings[semester] ||= Hash.new(0)
  end

  def check(semester)
    checks[semester] ||= {}
  end

  def update_loadings(semester, xml_or_hash)
    LOADING_ABBRS.each do |kind, abbr|
      value = (xml_or_hash[abbr] || xml_or_hash[kind]).to_i
      loading(semester)[kind] += value if value > 0
    end
  end

  def update_checks(semester, xml_or_hash)
    CHECK_ABBRS.each do |kind, abbr|
      check(semester)[kind] = true if xml_or_hash[abbr] || xml_or_hash[kind]
    end
  end

  def parse_nonpostal
    xml.css('>Сем').each do |semester_xml|
      update_loadings(semester_xml['Ном'].to_i, semester_xml)
      update_checks(semester_xml['Ном'].to_i, semester_xml)
    end
  end

  def parse_postal
    if has_subdisciplines?
      fill_checks_and_loadings_from_subdisciplines
    else
      xml.css('>Курс').each do |course_xml|
        if course_xml.at_css('>Сессия')
          course_xml.css('>Сессия').each do |session_xml|
            semester = POSTAL_SEMESTER_NUMBER[course_xml['Ном']][session_xml['Ном']]
            update_loadings(semester, session_xml)
            update_checks(semester, session_xml)
          end
        else
          fill_checks_from(course_xml)
        end
      end
    end
  end

  def fill_checks_and_loadings_from_subdisciplines
    subdisciplines.each do |subdiscipline|
      subdiscipline.parse
      subdiscipline.loadings.each do |semester, loadings|
        update_loadings(semester, loadings)
      end
      subdiscipline.checks.each do |semester, checks|
        update_checks(semester, checks)
      end
    end
  end

  def fill_checks_from(course_xml)
    CHECK_ABBRS.each do |kind, abbr|
      if session = course_xml[abbr]
        semester = POSTAL_SEMESTER_NUMBER[course_xml['Ном']][session]
        check(semester)[kind] = true
      end
    end
    LOADING_ABBRS.each do |kind, abbr|
      warn("'#{title}' #{course_xml['Ном']} курс #{kind} не разбиты по сессиям") if course_xml[abbr]
    end
  end

  def has_subdisciplines?
    subdisciplines.any?
  end

  def subdisciplines
    plan_importer.subdisciplines(cycle_id)
  end

  extend Memoist
  memoize :subdisciplines
end
