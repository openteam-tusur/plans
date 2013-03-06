class Requirement < ActiveRecord::Base
  attr_accessible :description, :work_programm_id, :kind
  validates_presence_of :work_programm_id, :kind

  belongs_to :work_programm

  extend Enumerize
  enumerize :kind, :in => %w[know be_able_to have]

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
#  kind :string(255)
#  description      :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

