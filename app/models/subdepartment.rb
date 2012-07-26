class Subdepartment < ActiveRecord::Base
  attr_accessible :abbr, :title, :number

  belongs_to :department
  has_many :subspecialities
  has_many :disciplines

  validates_presence_of :title, :abbr, :number, :department
  scope :actual, where(:deleted_at => nil)

  def chief(year_number)
    subdepartments = YAML.load_file("data/#{year_number}/departments.yml").map { |dep| dep['subdepartments'] }.flatten
    subdepartment_hash = subdepartments.select { |subdep_hash| subdep_hash['number'] == number }
    return Person::NIL unless subdepartment_hash
    subdepartment_hash = subdepartment_hash[0]
    return Person::NIL unless subdepartment_hash
    return Person::NIL unless subdepartment_hash['chief']
    Person.new(subdepartment_hash['chief'])
  end

  def nil_chief
  end
end
