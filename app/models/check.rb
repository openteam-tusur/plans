# encoding: utf-8

class Check < ActiveRecord::Base
  belongs_to :semester
  belongs_to :discipline
  attr_accessible :check_kind, :semester
  validates_presence_of :discipline_id, :check_kind, :semester_id

  scope :actual, ->() { where(:deleted_at => nil) }

  has_enum :check_kind

  REPORT_KINDS = {
    exam:               'Экзамен',
    end_of_term:        'Зачет',
    course_work:        'Диф. зачет',
    course_projecting:  'Диф. зачет',
  }

  def report_kind_value
    REPORT_KINDS[check_kind]
  end
end

# == Schema Information
#
# Table name: checks
#
#  id            :integer          not null, primary key
#  semester_id   :integer
#  discipline_id :integer
#  check_kind    :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  deleted_at    :datetime
#

