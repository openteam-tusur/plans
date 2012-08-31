class Department < ActiveRecord::Base
  attr_accessible :abbr, :title, :number, :subdepartments_attributes

  belongs_to :year
  belongs_to :context

  has_many :subdepartments, :dependent => :destroy

  validates_presence_of :title, :abbr, :year

  scope :actual, where(:deleted_at => nil)

  def chief(year_number)
    departments = YAML.load_file("data/#{year_number}/departments.yml")
    department_hash = departments.select { |dep_hash| dep_hash['abbr'] == abbr }.try(:first)
    return Person.nil unless department_hash
    return Person.nil unless department_hash['chief']
    Person.new(department_hash['chief'])
  end
end

# == Schema Information
#
# Table name: departments
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  abbr       :string(255)
#  number     :integer
#  year_id    :integer
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  context_id :integer
#

