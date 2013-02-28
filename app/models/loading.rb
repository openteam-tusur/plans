class Loading < ActiveRecord::Base
  belongs_to :semester
  belongs_to :discipline
  attr_accessible :loading_kind, :value, :semester_id

  validates_presence_of :semester_id, :discipline_id, :loading_kind, :value

  has_enum :loading_kind

  scope :actual, ->() { where(:deleted_at => nil) }

  def self.classroom_kinds
    enum_values(:loading_kind) - srs_kinds
  end

  def self.srs_kinds
    %w(srs exam)
  end
end

# == Schema Information
#
# Table name: loadings
#
#  id            :integer          not null, primary key
#  semester_id   :integer
#  discipline_id :integer
#  loading_kind  :string(255)
#  value         :integer
#  deleted_at    :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

