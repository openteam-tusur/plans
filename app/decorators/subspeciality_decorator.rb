# encoding: utf-8

class SubspecialityDecorator < Draper::Decorator
  delegate :semesters

  def headers
    @headers ||= ["Название дисциплины", "Экзамены", "Зачёты", "Курсовые работы / проекты"] + semesters.map(&:number)
  end

  def cycles_with_disciplines
    @cycles_with_disciplines ||= disciplines.group_by(&:cycle)
  end

  def columns_count
    @columns_count ||= headers.length
  end

  def disciplines
    @disciplines ||= model.disciplines
                          .actual
                          .includes(:checks)
                          .includes(:loadings)
                          .includes(:semesters)
                          .includes(:check_semesters)
                          .decorate
  end
end
