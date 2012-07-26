#encoding: utf-8

class Gos < ActiveRecord::Base
  attr_accessible :code, :title, :approved_on, :speciality_code

  has_many :didactic_units, :dependent => :destroy

  validates_presence_of :code, :title, :approved_on, :speciality_code

  validates_uniqueness_of :speciality_code

  def to_s
    "#{code} — #{title}"
  end

  def localized_approved_on
    "#{I18n.l(approved_on)} г." if approved_on?
  end
end
#--
# generated by 'annotated-rails' gem, please do not remove this line and content below, instead use `bundle exec annotate-rails -d` command
#++
# Table name: goses
#
# * id              :integer         not null
#   title           :text
#   code            :string(255)
#   created_at      :datetime        not null
#   updated_at      :datetime        not null
#   approved_on     :date
#   speciality_code :string(255)
#
#  Indexes:
#   index_goses_on_speciality_code  speciality_code
#--
# generated by 'annotated-rails' gem, please do not remove this line and content above, instead use `bundle exec annotate-rails -d` command
#++
