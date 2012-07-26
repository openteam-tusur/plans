class Loading < ActiveRecord::Base
  belongs_to :semester
  belongs_to :discipline
  attr_accessible :deleted_at, :loading_kind, :value, :semester

  has_enum :loading_kind

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

