class Appendix < ActiveRecord::Base
  attr_accessible :title, :appendix_items_attributes

  belongs_to :appendixable, :polymorphic => true

  has_many :appendix_items, :dependent => :destroy

  accepts_nested_attributes_for :appendix_items, :allow_destroy => true

  validates_presence_of :title
end
