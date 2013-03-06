# encoding: utf-8

class Check < ActiveRecord::Base
  belongs_to :semester
  belongs_to :discipline
  attr_accessible :check_kind, :semester
  validates_presence_of :discipline_id, :check_kind, :semester_id

  scope :actual, ->() { where(:deleted_at => nil) }

  extend Enumerize

  enumerize :check_kind, :in => %w[exam end_of_term course_work course_projecting], :scope => true
  delegate :text, :to => :check_kind, :prefix => true

  alias_attribute :kind_report, :check_kind
  enumerize :kind_report, :in => %w[exam end_of_term course_work course_projecting]
  delegate :text, :to => :kind_report, :prefix => true
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

