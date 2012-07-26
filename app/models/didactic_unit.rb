class DidacticUnit < ActiveRecord::Base
  attr_accessible :content, :discipline

  belongs_to :gos

  validates_presence_of :content, :discipline

  alias_attribute :to_s, :discipline
end

# == Schema Information
#
# Table name: didactic_units
#
#  id         :integer          not null, primary key
#  gos_id     :integer
#  discipline :string(255)
#  content    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

