# encoding: utf-8

class DisciplineXML
  attr_accessor :xml, :importer

  delegate :subspeciality, :cycle_node, :to => :importer

  def initialize(xml, importer)
    self.xml = xml
    self.importer = importer
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
end
