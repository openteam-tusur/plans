module ApplicationHelper
  def presentor
    @presentor ||= WorkProgrammPresentor.new(@work_programm)
  end
end
