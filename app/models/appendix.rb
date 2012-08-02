class Appendix < ActiveRecord::Base
  belongs_to :appendixable, :polymorphic => true
  attr_accessible :title
end
