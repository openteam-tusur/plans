# encoding: utf-8

class Year < ActiveRecord::Base
  attr_accessible :number

  has_many :departments, :dependent => :destroy
  has_many :subdepartments, :through => :departments

  has_many :specialities, :dependent => :destroy
  has_many :subspecialities, :through => :specialities

  has_many :actual_specialities, :class_name => 'Speciality'
  has_many :actual_subspecialities, :through => :actual_specialities

  validates_presence_of :number

  scope :actual, -> { where(:deleted_at => nil).order('years.number') }


  def degrees
    @degrees ||= actual_specialities.map(&:degree).uniq.sort
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

