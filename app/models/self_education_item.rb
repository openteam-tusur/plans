class SelfEducationItem < ActiveRecord::Base
  ALL_KINDS  = %w[lecture lab practice csr srs exam]

  belongs_to :work_programm
  attr_accessible :control, :hours, :kind

  scope :kind, ->(kind) { where :kind => kind }
end
