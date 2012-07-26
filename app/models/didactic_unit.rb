class DidacticUnit < ActiveRecord::Base
  attr_accessible :content, :discipline

  belongs_to :gos

  validates_presence_of :content, :discipline

  alias_attribute :to_s, :discipline
end
