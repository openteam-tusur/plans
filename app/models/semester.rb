class Semester < ActiveRecord::Base
  attr_accessible :number

  belongs_to :subspeciality

  has_many :exercises
  has_many :loadings, :dependent => :destroy
  has_many :checks

  has_many :disciplines, :through => :loadings, :uniq => true

  validates_presence_of :subspeciality, :number

  default_scope :order => :number

  scope :actual, ->() { where(:deleted_at => nil) }

  def to_s
    "#{number} #{self.class.model_name.human}"
  end

  def real_exercise_loading
    exercises.map(&:volume).sum
  end

  def planning_exercise_loading_for_discipline(discipline)
    loadings.where(:kind => 'lecture', :discipline_id => discipline).map(&:value).sum
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

