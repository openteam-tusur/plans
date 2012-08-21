class Requirement < ActiveRecord::Base
  attr_accessible :description, :work_programm_id, :requirement_kind
  validates_presence_of :work_programm_id, :requirement_kind

  belongs_to :work_programm

  has_enum :requirement_kind

  def to_s
    description
  end
end

# == Schema Information
#
# Table name: requirements
#
#  id               :integer          not null, primary key
#  work_programm_id :integer
#  requirement_kind :string(255)
#  description      :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

