class DisciplineDecorator < Draper::Decorator
  delegate :cycle, :title, :checks, :semesters

  def exam_semesters
    checks.select(&:check_kind_exam?).map(&:semester).map(&:number).join(', ')
  end

  def end_of_term_semesters
    checks.select(&:check_kind_end_of_term?).map(&:semester).map(&:number).join(', ')
  end

  def end_of_course_semesters
    check_semesters{ |c| c.check_kind_course_work? || c.check_kind_course_projecting? }
  end

  def loadings_in_semester?(semester)
    semesters.detect{|s| s == semester }
  end

  private

  def check_semesters(&block)
    checks.select(&block).map(&:semester).map(&:number).uniq.join(', ')
  end
end
