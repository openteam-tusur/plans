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

  def speciality_title
    speciality = Speciality.find_by_code(speciality_code)
    speciality ? speciality.title : 'не найдена'
  end
end

# == Schema Information
#
# Table name: goses
#
#  id              :integer          not null, primary key
#  title           :text
#  code            :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  approved_on     :date
#  speciality_code :string(255)
#

