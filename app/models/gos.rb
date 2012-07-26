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
    approved_on? ? "#{I18n.l(approved_on)} г." : '-'*10
  end
end
