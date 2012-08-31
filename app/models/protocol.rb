class Protocol < ActiveRecord::Base
  belongs_to :work_programm
  attr_accessible :number, :signed_on
  validates_presence_of :number, :signed_on, :on => :update
end

# == Schema Information
#
# Table name: protocols
#
#  id               :integer          not null, primary key
#  work_programm_id :integer
#  number           :string(255)
#  signed_on        :date
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

