class SelfEducation < ActiveRecord::Base
  belongs_to :work_programm
  attr_accessible :lecture_control, :lecture_hours, :lab_control, :lab_hours, :practice_control, :practice_hours, :csr_control, :csr_hours, :exam_control, :exam_hours, :srs_control, :srs_hours

  validates :lecture_hours, :presence => true, :numericality => { :only_integer => true, :greater_than => 0 }, :if => :need_lecture?
  validates :lecture_control, :presence => true, :if => :need_lecture?
  validates :lab_hours, :presence => true, :numericality => { :only_integer => true, :greater_than => 0 }, :if => :need_lab?
  validates :lab_control, :presence => true, :if => :need_lab?
  validates :practice_hours, :presence => true, :numericality => { :only_integer => true, :greater_than => 0 }, :if => :need_practice?
  validates :practice_control, :presence => true, :if => :need_practice?
  validates :csr_hours, :presence => true, :numericality => { :only_integer => true, :greater_than => 0 }, :if => :need_csr?
  validates :csr_control, :presence => true, :if => :need_csr?
  validates :srs_hours, :presence => true, :numericality => { :only_integer => true, :greater_than => 0 }, :if => :need_srs?
  validates :srs_control, :presence => true, :if => :need_exam?
  validates :exam_hours, :presence => true, :numericality => { :only_integer => true, :greater_than => 0 }, :if => :need_exam?
  validates :exam_control, :presence => true, :if => :need_exam?

  has_enums

  Exercise.enum_values(:kind).each do |value|
    define_method "need_#{value}?" do
      work_programm.has_loadings_for? value
    end
  end

  def need_exam?
    work_programm.has_loadings_for? 'exam'
  end

  def need_home_work?
  end

  def need_srs?
    work_programm.has_loadings_for? 'srs'
  end
end
