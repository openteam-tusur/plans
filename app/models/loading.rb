# == Schema Information
#
# Table name: loadings
#
#  id            :integer          not null, primary key
#  semester_id   :integer
#  discipline_id :integer
#  kind          :string(255)
#  value         :integer
#  deleted_at    :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Loading < ActiveRecord::Base
  belongs_to :semester
  belongs_to :discipline
  attr_accessible :kind, :value, :semester

  validates_presence_of :semester_id, :discipline_id, :kind, :value

  extend Enumerize
  enumerize :kind, :in => %w[lecture lab practice csr exam srs], :predicates => { :prefix => true }

  enumerize :abbr_kind, :in => %w[lecture lab practice csr]

  scope :actual, ->() { where(:deleted_at => nil) }

  CLASSROOM_KINDS = %w[lecture lab practice csr]

  def classroom?
    CLASSROOM_KINDS.include?(kind)
  end

  def abbr_kind
    Loading.abbr_kind.find_value(kind)
  end

  delegate :text, :to => :abbr_kind, :prefix => true
end
