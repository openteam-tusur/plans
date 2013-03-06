# encoding: utf-8

class DisciplineImporter
  attr_accessor :plan_importer, :xml, :imported, :discipline_xml

  delegate :subspeciality, :file_path, :year, :subspeciality_postal?, :to => :plan_importer
  delegate :find_subdepartment, :find_or_create_semester, :warn, :to => :plan_importer

  def initialize(plan_importer, discipline_xml)
    self.plan_importer = plan_importer
    self.xml = xml
    self.discipline_xml = discipline_xml
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
      discipline.cycle_id = discipline_xml.cycle_id
      discipline.summ_loading = discipline_xml.summ_loading
      discipline.summ_srs = discipline_xml.summ_srs
      discipline.cycle_code = discipline_xml.cycle_code
      discipline.kind = discipline_xml.kind
      refresh discipline
    end
  end

  extend Memoist

  memoize :discipline

  def create_checks
    discipline_xml.checks.each do |semester_number, checks|
      semester = find_or_create_semester(semester_number)
      checks.keys.each do |kind|
        discipline.checks.create! :semester => semester, :kind => kind
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

