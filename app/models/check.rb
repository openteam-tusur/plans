# encoding: utf-8
# == Schema Information
#
# Table name: checks
#
#  id            :integer          not null, primary key
#  semester_id   :integer
#  discipline_id :integer
#  kind          :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  deleted_at    :datetime
#


class Check < ActiveRecord::Base
  belongs_to :semester
  belongs_to :discipline
  attr_accessible :kind, :semester
  validates_presence_of :discipline_id, :kind, :semester_id

  scope :actual, ->() { where(:deleted_at => nil) }

  extend Enumerize

  enumerize :kind, :in => %w[exam end_of_term course_work course_projecting], :scope => true, :predicates => {:prefix => true}
  enumerize :kind_report, :in => %w[exam end_of_term end_of_term_diff]
  enumerize :plural_kind_report, :in => %w[exam end_of_term end_of_term_diff]

  def kind_report
    Check.kind_report.find_value(kind) || Check.kind_report.find_value('end_of_term_diff')
  end

  def plural_kind_report
    Check.plural_kind_report.find_value(kind) || Check.plural_kind_report.find_value('end_of_term_diff')
  end

  delegate :text, :to => :kind_report, :prefix => true
end
