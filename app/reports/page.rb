class Page
  attr_accessor :work_programm

  delegate :discipline, :to => :work_programm
  delegate :subspeciality, :subdepartment, :checks, :to => :discipline
  delegate :speciality, :to => :subspeciality
  delegate :department, :to => :subdepartment

  def initialize(work_programm)
    self.work_programm = work_programm
  end
end
