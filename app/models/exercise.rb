class Exercise < ActiveRecord::Base
  attr_accessible :description, :title, :volume, :semester_id, :kind, :work_programm_id

  belongs_to :semester
  belongs_to :work_programm

  has_one :appendix, :dependent => :destroy, :as => :appendixable

  validates_presence_of :title, :volume, :semester, :kind
  validates_numericality_of :volume, :greater_than => 0, :only_integer => true

  default_scope order('exercises.weight, exercises.id ASC')

  before_create :set_weight

  extend Enumerize
  enumerize :kind, :in => %w[lecture lab practice csr], :scope => true
  enumerize :add_kind, :in => %w[lecture lab practice csr]
  enumerize :pluralize_kind, :in => %w[lecture lab practice csr srs]

  WORK_PROGRAMM_KINDS = kind.values + ['srs']

  def set_weight
    self.weight = Exercise.kind.values.index(kind)
  end
end

# == Schema Information
#
# Table name: exercises
#
#  id               :integer          not null, primary key
#  title            :text
#  description      :text
#  volume           :integer
#  work_programm_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  semester_id      :integer
#  kind             :string(255)
#  weight           :integer
#

