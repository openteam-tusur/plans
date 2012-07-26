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
