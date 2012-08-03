class ExaminationQuestion < ActiveRecord::Base
  attr_accessible :question_kind, :score, :semester_id

  belongs_to :work_programm
  belongs_to :semester

  validates_presence_of :question_kind, :score, :semester_id
end

# == Schema Information
#
# Table name: examination_questions
#
#  id               :integer          not null, primary key
#  work_programm_id :integer
#  semester_id      :integer
#  question_kind    :string(255)
#  score            :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

