class Mission < ActiveRecord::Base
  attr_accessible :description
  belongs_to :work_programm
  validates_presence_of :description, :work_programm_id

  def to_s
    description
  end
end
