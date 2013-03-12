# encoding: utf-8

class Year < ActiveRecord::Base
  attr_accessible :number

  has_many :specialities, :dependent => :destroy
  has_many :subspecialities, :through => :specialities

  has_many :actual_specialities, :class_name => 'Speciality'
  has_many :actual_subspecialities, :through => :actual_specialities

  validates_presence_of :number

  scope :actual, -> { where(:deleted_at => nil).ordered }
  scope :ordered, -> { order('years.number') }

  def all_degrees
    actual_specialities.map(&:degree).uniq.sort
  end

  def degrees(education_form)
    actual_subspecialities.select{|ss| ss.education_form == education_form}.map(&:speciality).map(&:degree).uniq.sort
  end

  def to_param
    number
  end

  def to_s
    "#{number} год"
  end
end

# == Schema Information
#
# Table name: years
#
#  id         :integer          not null, primary key
#  number     :integer
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

