class SelfEducation < ActiveRecord::Base
  belongs_to :work_programm
  attr_accessible :lecture_control, :lecture_hours

  validates :lecture_hours, :numericality => { :only_integer => true, :greater_than => 0 }

  has_enum :lecture_control, :multiple => true
end
