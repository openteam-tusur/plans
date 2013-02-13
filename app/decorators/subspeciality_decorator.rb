# encoding: utf-8

class SubspecialityDecorator < Draper::Decorator
  delegate :title, :semesters, :work_plan, :gos_generation

  decorates_association :speciality

  def headers
    @headers ||= ["№<br/>п/п".html_safe, "Название дисциплины", "Экз", "Зач", "КрР/<br/>КрПр".html_safe] + semesters.map(&:number)
  end

  def cycles_with_disciplines
    @cycles_with_disciplines ||= disciplines.group_by(&:cycle)
  end

  def columns_count
    @columns_count ||= headers.length
  end

  def year
    model.year.number
  end

  def graduated_subdepartment
    model.graduated_subdepartment.abbr
  end

  def education_form
    model.human_education_form.gsub /форма$/, ''
  end

  def has_disciplines?
    model.actual_disciplines.length > 0
  end

  def disciplines
    @disciplines ||= model.actual_disciplines
                          .includes(:checks)
                          .includes(:loadings)
                          .includes(:semesters)
                          .includes(:check_semesters)
                          .decorate
  end
end
