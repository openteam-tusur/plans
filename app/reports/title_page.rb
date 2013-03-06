# encoding: utf-8

class TitlePage < Page
  def scheduling
    Scheduling.new(self, discipline)
  end

  def date_line
    "«____» _____________________ #{work_programm.year} г."
  end

  def discipline_title
    "#{discipline.title} (#{discipline.cycle_code})"
  end

  def speciality_title
    "#{speciality.code} #{speciality.title}"
  end

  def speciality_kind
    speciality.degree.specialty? ? 'Специальность' : 'Направление'
  end

  def department_title
    department.title.gsub(/факультет/i, '').squish.sub(/^(.)/) { $1.mb_chars.upcase }
  end

  def subdepartment_title
    provided_subdepartment.title.gsub(/кафедра/i, '').squish.sub(/^(.)/) { $1.mb_chars.upcase }
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
    discipline.checks.group_by(&:kind_report_text).each do |kind, checks|
      hash[kind] =  "#{checks.map(&:semester).map(&:number).sort.join(', ')} семестр"
    end
    hash
  end

  def year_line
    work_programm.year.to_s
  end

  def loaded_semesters
    @loaded_semesters ||= discipline.loadings.map(&:semester).uniq.map(&:number).sort
  end

  def loaded_courses
    loaded_semesters.map { |s| (s.to_f / 2).round }.uniq
  end

end
