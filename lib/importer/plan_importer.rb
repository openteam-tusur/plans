# encoding: utf-8

class PlanImporter
  SPECIALITY_CODE = '\d{6}(?:\.(?:62|65|68))?'

  SEMESTER_NUMBERS = {
    '1' => 1,
    '2' => 2,
    '3' => 3,
    '4' => 4,
    '5' => 5,
    '6' => 6,
    '7' => 7,
    '8' => 8,
    '9' => 9,
    'A' => 10,
    'B' => 11,
    'C' => 12,
    'D' => 13,
    '10' => 10,
    '11' => 11,
    '12' => 12,
    '13' => 13,
  }

  attr_accessor :file_path, :options

  delegate :postal?, :to => :subspeciality, :prefix => true

  def initialize(file_path, options={})
    self.file_path = file_path
    self.options = options
  end

  def import
    Timecop.freeze(time_of_sync) do
      check_year
      if subspeciality.plan_digest != file_path_digest
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
    year.specialities.actual.find_by_code!(speciality_code) do |speciality|
      speciality.update_attribute :gos_generation, title_node['ТипГОСа'] || 2
    end
  end

  SUBSPECIALITY_PREFIX_BY_DEGREE = {
    'bachelor'   => 'Профиль',
    'magistracy' => 'Магистерская программа',
    'specialty'  => 'Специализация',
  }

  def subspeciality_prefix
    SUBSPECIALITY_PREFIX_BY_DEGREE[speciality.degree]
  end

  def subspeciality_node
    xml.at_css("Специальность[Название^='#{subspeciality_prefix}']") ||
      xml.at_css("Специальность[Название^='#{subspeciality_prefix.mb_chars.downcase}']")
  end

  def subspeciality_node_title
    subspeciality_node['Название'].squish
  end

  def get_subspeciality_title
    if subspeciality_node
      prefix = "#{subspeciality_prefix}(?: -)?"
      match = subspeciality_node_title.match(/"(.*?)"/) ||
        subspeciality_node_title.gsub(/"/, '').match(/^#{prefix} (.*?)$/i)
      match.try(:captures).try(:first)
    end
  end

  def subspeciality_title
    get_subspeciality_title || default_subspeciality_title
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
    speciality.subspecialities.actual
      .find_by_title_and_subdepartment_id_and_education_form_and_reduced!(subspeciality_title,
                                                                          find_subdepartment(subdepartment_number),
                                                                          education_form,
                                                                          reduced)
  end

  def subspeciality
    find_subspeciality.tap do |subspeciality|
      subspeciality.update_attributes! :file_path => nil, :plan_digest => nil if options[:force]
      raise "#{subspeciality.import_to_s} уже обновлялась (#{subspeciality.file_path})" if subspeciality.file_path?
      subspeciality.update_attribute :file_path, file_path
    end
  end

  def file_path_digest
    Digest::SHA256.hexdigest open(file_path).read
  end

  def find_or_create_semester(number_str)
    number = SEMESTER_NUMBERS[number_str.to_s] or raise "incorrect semester number #{string} (#{string.ord})"
    subspeciality.semesters.find_or_initialize_by_number(number).tap do |semester|
      semester.deleted_at = nil
      semester.save!
    end
  end

  extend Memoist
  memoize :xml, :title_node, :year, :year_number, :speciality_full_name, :speciality_code
  memoize :speciality, :subspeciality_title, :education_form, :reduced, :subspeciality, :file_path_digest
  memoize :find_subdepartment, :subspeciality_node, :find_or_create_semester

  def human_education_form
    speciality_full_name.match(/(заочная с дистанционной технологией|очно-заочная|очная|заочная)/).try(:captures).try(:first)  || 'очная'
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
    Check.where(:id => Check.joins(:discipline).where('disciplines.subspeciality_id' => subspeciality.id).pluck('disciplines.id')).delete_all
    Loading.where(:id => Loading.joins(:discipline).where('disciplines.subspeciality_id' => subspeciality.id).pluck('disciplines.id')).delete_all
    move_to_trash(:disciplines, :semesters, :object => subspeciality)
  end

  def really_import
    reset_acuality_of_associations

    xml.css('СтрокиПлана Строка').each do |discipline_xml|
      DisciplineImporter.new(self, discipline_xml).import
    end
    subspeciality.update_column(:plan_digest, file_path_digest)
  end
end
