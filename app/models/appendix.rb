class Appendix < ActiveRecord::Base
  belongs_to :work_programm
  attr_accessible :title, :kind

  scope :kind, ->(kind) { where(:kind => kind) }
end
