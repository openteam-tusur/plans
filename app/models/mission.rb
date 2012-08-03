class Mission < ActiveRecord::Base
  attr_accessible :description
  belongs_to :work_programm
  validates_presence_of :description, :work_programm_id

  def to_s
    description
  end
end

# == Schema Information
#
# Table name: missions
#
#  id               :integer          not null, primary key
#  description      :text
#  work_programm_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

