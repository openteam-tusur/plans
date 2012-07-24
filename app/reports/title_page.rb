# encoding: utf-8

class TitlePage
  attr_accessor :work_programm
  attr_accessor :scheduling

  delegate :discipline, :to => :work_programm
  delegate :subspeciality, :subdepartment, :checks, :to => :discipline
  delegate :speciality, :to => :subspeciality
  delegate :department, :to => :subdepartment

  def initialize(work_programm)
    self.work_programm = work_programm
    self.scheduling = Scheduling.new(self, discipline)
  end

  def date_line
    "«____» _____________________ #{work_programm.year} г."
  end

  def discipline_title
    "#{discipline.title} (#{discipline.code})"
  end

  def speciality_title
    "#{speciality.code} #{speciality.title}"
  end

  def speciality_kind
    speciality.degree == 'specialty' ? 'Специальность' : 'Направление'
  end

  def department_title
    department.title.gsub(/факультет/i, '').squish.sub(/^(.)/) { $1.mb_chars.upcase }
  end

  def subdepartment_title
    subdepartment.title.gsub(/кафедра/i, '').squish.sub(/^(.)/) { $1.mb_chars.upcase }
  end

  def courses
    loaded_courses.join(', ')
  end

  def semesters
    loaded_semesters.join(', ')
  end

  def speciality_year
    "Учебный план набора #{speciality.year.number} года и последующих лет"
  end

  def checks
    hash = {}
    discipline.checks.group_by(&:report_kind_value).each do |check_kind, checks|
      hash[check_kind] =  "#{checks.map(&:semester).map(&:number).join(', ')} семестр"
    end
    hash
  end

  def year_line
    work_programm.year.to_s
  end

  def loaded_semesters
    @loaded_semesters ||= discipline.loadings.map(&:semester).uniq.map(&:number)
  end

  def loaded_courses
    loaded_semesters.map { |s| (s.to_f / 2).round }.uniq
  end

end
