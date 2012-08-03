class AppendixItem < ActiveRecord::Base
  attr_accessible :description

  belongs_to :appendix

  validates_presence_of :description
end

# == Schema Information
#
# Table name: appendix_items
#
#  id          :integer          not null, primary key
#  appendix_id :integer
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

