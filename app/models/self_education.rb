class SelfEducation < ActiveRecord::Base
  belongs_to :work_programm
  attr_accessible :lecture_control, :lecture_hours, :lab_control, :lab_hours

  validates :lecture_hours, :presence => true, :numericality => { :only_integer => true, :greater_than => 0 }, :if => :need_lecture?
  validates :lecture_control, :presence => true, :if => :need_lecture?
  validates :lab_hours, :presence => true, :numericality => { :only_integer => true, :greater_than => 0 }, :if => :need_lab?
  validates :lab_control, :presence => true, :if => :need_lab?

  has_enums

  Exercise.enum_values(:kind).each do |value|
    define_method "need_#{value}?" do
      work_programm.has_loadings_for? value
    end
  end
end
