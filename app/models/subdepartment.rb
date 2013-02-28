# encoding: utf-8

class Subdepartment < ActiveRecord::Base
  attr_accessible :abbr, :title, :number

  belongs_to :department
  has_many :subspecialities
  has_many :disciplines
  has_many :actual_disciplines, :class_name => 'Discipline', :conditions => { :deleted_at => nil }

  validates_presence_of :title, :abbr, :number, :department
  scope :actual, where(:deleted_at => nil)

  def chief(year_number)
    subdepartments = YAML.load_file("data/#{year_number}/departments.yml").map { |dep| dep['subdepartments'] }.flatten
    subdepartment_hash = subdepartments.select { |subdep_hash| subdep_hash['number'] == number }.try(:first)
    return Person.nil unless subdepartment_hash
    return Person.nil unless subdepartment_hash['chief']
    Person.new(subdepartment_hash['chief'])
  end

  def to_s
    "Кафедра #{abbr}"
  end
end

# == Schema Information
#
# Table name: subdepartments
#
#  id            :integer          not null, primary key
#  title         :string(255)
#  abbr          :string(255)
#  number        :integer
#  department_id :integer
#  deleted_at    :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  context_id    :integer
#

