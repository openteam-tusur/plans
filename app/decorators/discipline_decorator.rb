class DisciplineDecorator < Draper::Decorator
  delegate :cycle, :title, :checks, :semesters, :subspeciality, :cycle_code, :work_programms

  def work_programm
    work_programms.first if work_programms.length > 0
  end

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
    semesters.detect{|s| s == semester }
  end

  private

  def check_semesters(&block)
    checks.select(&block).map(&:semester).map(&:number).uniq.join(', ')
  end
end
