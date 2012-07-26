class Year < ActiveRecord::Base
  attr_accessible :number

  has_many :departments, :dependent => :destroy
  has_many :subdepartments, :through => :departments

  has_many :specialities, :dependent => :destroy
  has_many :subspecialities, :through => :specialities

  validates_presence_of :number
  after_save :move_descendants_to_trash, :if => [:deleted_at_changed?, :deleted_at?]

  def to_param
    number
  end

  def move_descendants_to_trash
    departments.update_all(:deleted_at =>  Time.now)
    specialities.update_all(:deleted_at => Time.now)
    subdepartments.update_all(:deleted_at => Time.now)
    subspecialities.update_all(:deleted_at => Time.now)
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

