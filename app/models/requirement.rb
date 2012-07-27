class Requirement < ActiveRecord::Base
  attr_accessible :description, :work_programm_id, :kind
  validates_presence_of :work_programm_id, :kind

  has_enum :kind, [:know, :be_able_to, :have ]

  def to_s
    description
  end
end
