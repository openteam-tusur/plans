class Loading < ActiveRecord::Base
  belongs_to :semester
  belongs_to :discipline
  attr_accessible :kind, :value, :semester

  validates_presence_of :semester_id, :discipline_id, :kind, :value

  extend Enumerize
  enumerize :kind, :in => %w[lecture lab practice csr exam srs], :predicates => { :prefix => true }

  scope :actual, ->() { where(:deleted_at => nil) }
end

# == Schema Information
#
# Table name: loadings
#
#  id            :integer          not null, primary key
#  semester_id   :integer
#  discipline_id :integer
#  kind  :string(255)
#  value         :integer
#  deleted_at    :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

