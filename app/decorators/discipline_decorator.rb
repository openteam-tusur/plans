class DisciplineDecorator < Draper::Decorator
  delegate :cycle, :title, :actual_checks, :actual_semesters

  def exam_semesters
    check_semesters(&:check_kind_exam?)
  end

  def end_of_term_semesters
    check_semesters(&:check_kind_end_of_term?)
  end

  def end_of_course_semesters
    check_semesters{ |c| c.check_kind_course_work? || c.check_kind_course_projecting? }
  end

  def loadings_in_semester?(semester)
    actual_semesters.detect{|s| s == semester }
  end

  private

  def check_semesters(&block)
    actual_checks.select(&block).map(&:semester).map(&:number).uniq.join(', ')
  end
end
