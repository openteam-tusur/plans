# == Schema Information
#
# Table name: departments
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  abbr       :string(255)
#  number     :integer
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Department < ActiveRecord::Base
  attr_accessible :abbr, :title, :number

  has_many :subdepartments, :dependent => :destroy

  validates_presence_of :title, :abbr

  def chief(year_number)
    departments = YAML.load_file("data/#{year_number}/departments.yml")
    department_hash = departments.select { |dep_hash| dep_hash['abbr'] == abbr }.try(:first)
    return Person.nil unless department_hash
    return Person.nil unless department_hash['chief']
    Person.new(department_hash['chief'])
  end
end
