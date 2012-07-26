class Exercise < ActiveRecord::Base
  attr_accessible :description, :title, :volume, :semester_id, :kind, :work_programm_id

  belongs_to :semester
  belongs_to :work_programm

  validates_presence_of :description, :title, :volume, :semester, :kind

  default_scope order('id ASC')

  has_enum :kind, [:lecture, :lab, :practice, :srs]
end
