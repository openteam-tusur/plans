class ExaminationQuestion < ActiveRecord::Base
  attr_accessible :question_kind, :score, :semester_id

  belongs_to :work_programm
  belongs_to :semester

  validates_presence_of :question_kind, :score, :semester_id
end
