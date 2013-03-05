# encoding: utf-8

class DisciplineXML
  attr_accessor :xml, :importer
  attr_accessor :loadings, :checks

  delegate :subspeciality, :cycle_node, :warn, :to => :importer

  def initialize(xml, importer)
    self.xml = xml
    self.importer = importer
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
    parse_postal
    parse_nonpostal
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

  def update_loadings(semester, xml)
    LOADING_ABBRS.each do |kind, abbr|
      loading(semester)[kind] += xml[abbr].to_i if xml[abbr]
    end
  end

  def update_checks(semester, xml)
    CHECK_ABBRS.each do |kind, abbr|
      check(semester)[kind] ||= true if xml[abbr]
    end
  end

  def parse_nonpostal
    xml.css('>Сем').each do |semester_xml|
      update_loadings(semester_xml['Ном'].to_i, semester_xml)
      update_checks(semester_xml['Ном'].to_i, semester_xml)
    end
  end

  def parse_postal
    xml.css('>Курс').each do |course_xml|
      if course_xml.at_css('>Сессия')
        course_xml.css('>Сессия').each do |session_xml|
          semester = POSTAL_SEMESTER_NUMBER[course_xml['Ном']][session_xml['Ном']]
          update_loadings(semester, session_xml)
          update_checks(semester, session_xml)
        end
      else
        warn("'#{title}' #{course_xml['Ном']} курс не разбит по сессиям")
      end
    end
  end
end
