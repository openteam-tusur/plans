class Page
  attr_accessor :work_programm

  delegate :discipline, :provided_subdepartment, :profiled_subdepartment, :graduated_subdepartment, :to => :work_programm
  delegate :subspeciality, :checks, :to => :discipline
  delegate :speciality, :to => :subspeciality
  delegate :department, :to => :provided_subdepartment

  def initialize(work_programm)
    self.work_programm = work_programm
  end
end
