# encoding: utf-8
Semester
class SubspecialityDecorator < Draper::Decorator
  delegate :title, :actual_semesters, :work_plan, :gos_generation, :graduated_subdepartment, :human_education_form, :year

  decorates_association :speciality

  def headers
    @headers ||= ["№<br/>п/п".html_safe, "Название дисциплины", "Экз", "Зач", "КрР/<br/>КрПр".html_safe] + actual_semesters.map(&:number)
  end

  def full_title
    "#{speciality.gos}. #{speciality.full_title} (#{title})"
  end

  def extra_info
    "#{speciality.degree}. #{graduated_subdepartment}. #{year} начала подготовки. #{capitalized_education_form} обучения."
  end

  def cycles_with_disciplines
    @cycles_with_disciplines ||= disciplines.group_by(&:cycle)
  end

  def columns_count
    @columns_count ||= headers.length
  end

  def year_number
    year.number
  end

  def subdepartment
    graduated_subdepartment.abbr
  end

  def education_form
    human_education_form.gsub /форма$/, ''
  end

  def capitalized_education_form
    human_education_form.tap do |string|
      string[0] = string[0].mb_chars.capitalize!
    end
  end

  def has_disciplines?
    model.actual_disciplines.length > 0
  end

  def disciplines
    @disciplines ||= model.actual_disciplines
                          .includes(:actual_checks)
                          .includes(:actual_loadings)
                          .includes(:actual_semesters)
                          .decorate
  end
end
