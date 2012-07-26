class Department < ActiveRecord::Base
  attr_accessible :abbr, :title, :number, :subdepartments_attributes

  belongs_to :year

  has_many :subdepartments, :dependent => :destroy

  validates_presence_of :title, :abbr, :year

  scope :actual, where(:deleted_at => nil)

  def chief(year_number)
    departments = YAML.load_file("data/#{year_number}/departments.yml")
    department_hash = departments.select { |dep_hash| dep_hash['abbr'] == abbr }
    return Person::NIL unless department_hash
    department_hash = department_hash[0]
    return Person::NIL unless department_hash
    return Person::NIL unless department_hash['chief']
    Person.new(department_hash['chief'])
  end
end
