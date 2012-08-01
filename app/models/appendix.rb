class Appendix < ActiveRecord::Base
  belongs_to :work_programm
  attr_accessible :title, :kind
  scope :kind, ->(kind) { where(:kind => kind) }

  ALL_KINDS   = %w[lab practice csr home_work referat test colloquium calculation srs exam]
end
