class Requirement < ActiveRecord::Base
  attr_accessible :description, :work_programm_id, :requirement_kind
  validates_presence_of :work_programm_id, :requirement_kind

  has_enum :requirement_kind

  def to_s
    description
  end
end
