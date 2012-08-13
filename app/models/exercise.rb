class Exercise < ActiveRecord::Base
  attr_accessible :description, :title, :volume, :semester_id, :kind, :work_programm_id

  belongs_to :semester
  belongs_to :work_programm

  has_one :appendix, :dependent => :destroy, :as => :appendixable

  validates_presence_of :title, :volume, :semester, :kind
  validates_numericality_of :volume, :greater_than => 0, :only_integer => true

  default_scope order('exercises.weight, exercises.id ASC')

  before_create :set_weight

  has_enum :kind

  def set_weight
    self.weight = Exercise.enum_values(:kind).index(kind)
  end
end

# == Schema Information
#
# Table name: exercises
#
#  id               :integer          not null, primary key
#  title            :string(255)
#  description      :text
#  volume           :integer
#  work_programm_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  semester_id      :integer
#  kind             :string(255)
#  weight           :integer
#

