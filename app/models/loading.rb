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
