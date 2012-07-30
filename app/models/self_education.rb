class SelfEducation < ActiveRecord::Base
  belongs_to :work_programm
  attr_accessible :lecture_control, :lecture_hours

  validates :lecture_hours, :presence => true, :numericality => { :only_integer => true, :greater_than => 0 }, :if => :need_lecture?

  has_enum :lecture_control, :multiple => true

  def need_lecture?
    work_programm.has_loadings_for? :lecture
  end
end
