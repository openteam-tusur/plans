# encoding: utf-8

class SubspecialityDecorator < Draper::Decorator
  delegate :title, :actual_semesters, :work_plan, :programm, :gos_generation, :graduated_subdepartment, :year, :reduced_text, :education_form_text,
    :speciality_code, :speciality_title, :kind, :kind_text, :actual_disciplines

  decorates_association :speciality

  def headers
    @headers ||= ["№<br/>п/п".html_safe, "Цикл", "Название дисциплины", "Кафедра", "Экз", "Зач", "КрР/<br/>КрПр".html_safe] + actual_semesters.map(&:number)
  end

  def speciality_code_with_title
    { code: speciality_code, title: speciality_title }
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

  def title_with_edu_form_and_year
    content = "#{capitalized_education_form} форма обучения"
    content += " #{reduced_text}" unless reduced_text.blank?
    content += ", план набора #{year_number} г. и последующих лет"
    content += " (#{kind_text})" unless kind.basic?
    content = h.content_tag :p, content
  end

  def linked_title
    return "" if title.match /^Без (профиля|специализации)$/
    h.content_tag :p, "#{I18n.t("degree.profile.#{degree_value}")}: #{link_to_show(title)}".html_safe unless title.match(/^Без/)
  end

  def link_to_show(text)
    has_disciplines? ? h.link_to(text.html_safe, [:edu, model]) : text.html_safe
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
    model.actual_disciplines.count > 0
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
    actual_semesters.includes(:loadings, :checks, :subspeciality)
  end
end
