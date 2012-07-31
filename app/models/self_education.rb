class SelfEducation < ActiveRecord::Base
  belongs_to :work_programm
  attr_accessible :lecture_control, :lecture_hours, :lab_control, :lab_hours, :practice_control, :practice_hours, :csr_control, :csr_hours, :exam_control, :exam_hours, :srs_control, :srs_hours

  has_enums

  Loading.enum_values(:loading_kind).each do |value|
    validates "#{value}_hours",
              :presence => true,
              :numericality => { :only_integer => true, :greater_than_or_equal_to  => 0 },
              :if => :"need_#{value}?"

    default_value_for "#{value}_hours", 0

    define_method "need_#{value}?" do
      work_programm.has_loadings_for? value
    end
  end

  def need_home_work?
  end

  def total_hours
    [lecture_hours, lab_hours, practice_hours, csr_hours, srs_hours, exam_hours].sum
  end
end
