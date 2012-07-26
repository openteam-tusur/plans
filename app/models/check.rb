class Check < ActiveRecord::Base
  belongs_to :semester
  belongs_to :discipline
  attr_accessible :check_kind, :semester
  validates_presence_of :semester, :discipline, :check_kind

  has_enum :check_kind

  def report_kind_value
    I18n.t check_kind, :scope => 'activerecord.attributes.check.check_kind_reports'
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

