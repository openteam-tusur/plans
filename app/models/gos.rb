# encoding: utf-8

class Gos < ActiveRecord::Base
  attr_accessible :code, :title, :approved_on, :speciality_code

  has_many :didactic_units, :dependent => :destroy

  validates_presence_of :code, :title, :approved_on, :speciality_code

  validates_uniqueness_of :speciality_code

  def to_s
    "#{code} — #{title}"
  end

  def localized_approved_on
    approved_on? ? I18n.l(approved_on, :format => '%d %B %Y г.') : '-'*10
  end

  def didactic_units_complete?
    (disciplines.pluck('disciplines.title').uniq - didactic_units.pluck('discipline')).empty? && didactic_units.any?
  end

  def disciplines
    Discipline.where(:subspeciality_id => subspecialities.pluck(:id)).where('disciplines.cycle_code LIKE ?', '%.Ф')
  end

  def subspecialities
    Subspeciality.where(:speciality_id => specialities.pluck(:id))
  end

  def specialities
    Speciality.where(:code => speciality_code)
  end

  def speciality_title
    specialities.any? ? specialities.pluck(:title).uniq.join(', ') : 'специальность не найдена'
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
#  html            :text
#

