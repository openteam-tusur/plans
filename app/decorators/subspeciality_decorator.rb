# encoding: utf-8

class SubspecialityDecorator < Draper::Decorator
  delegate :title, :actual_semesters, :work_plan, :gos_generation, :graduated_subdepartment, :year, :reduced_text, :education_form_text

  decorates_association :speciality

  def headers
    @headers ||= ["№<br/>п/п".html_safe, "Цикл", "Название дисциплины", "Экз", "Зач", "КрР/<br/>КрПр".html_safe] + actual_semesters.map(&:number)
  end

  def full_title
    "#{speciality.gos}. #{speciality.full_title} (#{title})"
  end

  def extra_info
    "#{speciality.degree}. #{graduated_subdepartment}. #{year} начала подготовки. #{capitalized_education_form} форма #{reduced_text} обучения."
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

  def reduced
    h.content_tag :p, reduced_text, :class => 'reduced' if reduced_text
  end

  def education_form
    h.content_tag :p, capitalized_education_form
  end

  def capitalized_education_form
    education_form_text.tap do |string|
      string[0] = string[0].mb_chars.capitalize!
    end
  end

  def has_disciplines?
    model.actual_disciplines.length > 0
  end

  def degree
    speciality.degree
  end

  def degree_value
    speciality.model.degree
  end

  def disciplines
    @disciplines ||= model.actual_disciplines
                          .includes(:work_programms, :loadings, :semesters, :checks => :semester)
                          .order('cycle_id, title')
                          .decorate
  end

  def semesters
    actual_semesters.includes(:loadings, :checks, :disciplines => [:loadings, :checks, :subdepartment])
  end
end
