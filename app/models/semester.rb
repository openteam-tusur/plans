class Semester < ActiveRecord::Base
  attr_accessible :number

  belongs_to :subspeciality

  has_many :exercises
  has_many :loadings, :dependent => :destroy

  validates_presence_of :subspeciality, :number

  default_scope :order => :number

  def to_s
    "#{number} #{self.class.model_name.human}"
  end

  def real_exercise_loading
    exercises.map(&:volume).sum
  end

  def planning_exercise_loading_for_discipline(discipline)
    loadings.where(:loading_kind => 'lecture', :discipline_id => discipline).map(&:value).sum
  end
end

# == Schema Information
#
# Table name: semesters
#
#  id               :integer          not null, primary key
#  subspeciality_id :integer
#  number           :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  deleted_at       :datetime
#

