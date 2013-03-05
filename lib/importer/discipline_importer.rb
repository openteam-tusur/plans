# encoding: utf-8

class DisciplineImporter
  attr_accessor :plan_importer, :xml, :imported, :discipline_xml

  delegate :subspeciality, :file_path, :year, :cycle_node, :subspeciality_postal?, :to => :plan_importer
  delegate :find_subdepartment, :find_or_create_semester, :warn, :to => :plan_importer

  def initialize(plan_importer, xml)
    self.plan_importer = plan_importer
    self.xml = xml
    self.discipline_xml = DisciplineXML.new(xml, self)
  end

  def discipline_subdepartment
    discipline_xml.subdepartment_number ? find_subdepartment(discipline_xml.subdepartment_number) : subspeciality.subdepartment
  end

  def find_discipline
    subspeciality.disciplines.find_or_initialize_by_title(discipline_xml.title)
  end

  def discipline
    find_discipline.tap do |discipline|
      discipline.subdepartment = discipline_subdepartment
      discipline.cycle = discipline_xml.cycle
      discipline.summ_loading = discipline_xml.summ_loading
      discipline.summ_srs = discipline_xml.summ_srs
      discipline.cycle_code = discipline_xml.cycle_code
      refresh discipline
    end
  end

  extend Memoist

  memoize :discipline

  def create_checks
    discipline_xml.checks.each do |semester_number, checks|
      semester = find_or_create_semester(semester_number)
      checks.keys.each do |kind|
        discipline.checks.create! :semester => semester, :check_kind => kind
      end
    end
  end

  def create_loadings
    discipline_xml.loadings.each do |semester_number, loadings|
      semester = find_or_create_semester(semester_number)
      loadings.each do |kind, value|
        discipline.loadings.create! :semester => semester, :loading_kind => kind, :value => value
      end
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
          warn("'#{discipline_xml.title}' #{course_xml['Ном']} курс: #{kind}(#{loading_value}) не распределен по семестрам")
          create_loading (course_xml['Ном'].to_i * 2 - 1), kind, (loading_value/2)
          create_loading (course_xml['Ном'].to_i * 2), kind, (loading_value - loading_value/2)
        end
      end
    end
  end

  def import
    if discipline_xml.valid?
      discipline.save!
      discipline_xml.parse
      create_loadings
      create_checks
    else
      warn("у дисциплины '#{discipline_xml.title}' не указан цикл")
    end
  rescue => e
    warn("не могу импорировать дисциплину #{discipline_xml.title}")
    raise e
  end
end

