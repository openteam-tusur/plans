# encoding: utf-8

class YearImporter
  attr_accessor :year_number, :bar

  def initialize(year_number)
    self.year_number = year_number
  end

  def import
    year.save!
    puts year.number
    self.bar = ProgressBar.new(Dir["data/#{year.number}/**/*.{xml,yml}"].count)
    import_specialities
    import_plans
    puts
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
          subdepartment = Subdepartment.find_by_abbr(subspeciality_attributes['subdepartment'])
          raise "Нет кафедры #{subspeciality_attributes['subdepartment']}" unless subdepartment
          graduated_subdepartment = Subdepartment.find_by_abbr(subspeciality_attributes['graduated_subdepartment'] || subspeciality_attributes['subdepartment'])
          department = Department.find_by_abbr(subspeciality_attributes['department']) || subdepartment.department
          subspeciality = speciality.subspecialities.find_or_initialize_by_title_and_subdepartment_id_and_education_form_and_reduced(
            :title            => subspeciality_attributes['title'].squish,
            :subdepartment_id => subdepartment.id,
            :education_form   => subspeciality_attributes['education_form'] || 'full-time',
            :reduced          => subspeciality_attributes['reduced']
          )
          subspeciality.graduated_subdepartment = graduated_subdepartment
          subspeciality.department = department
          subspeciality.group_index = subspeciality_attributes['group_index']
          subspeciality.file_path = nil
          refresh subspeciality
          begin
            subspeciality.save!
          rescue => e
            puts subspeciality.import_to_s
            raise e
          end
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
        puts e.backtrace.join("\n")
      end
      bar.increment!
    end
  end

  private

  def year
    Year.find_or_initialize_by_number(year_number).tap do |year|
      refresh year
    end
  end

  extend Memoist
  memoize :year
end


