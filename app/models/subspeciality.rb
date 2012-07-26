# encoding: utf-8

class Subspeciality < ActiveRecord::Base
  attr_accessible :title, :subdepartment_id, :graduate_subdepartment_id

  alias_attribute :deleted?, :deleted_at?

  belongs_to :speciality
  belongs_to :subdepartment
  belongs_to :graduate_subdepartment, :class_name => 'Subdepartment'

  has_one :programm, :as => :with_programm
  has_many :disciplines, :dependent => :destroy
  has_many :semesters, :dependent => :destroy

  validates_presence_of :title, :speciality, :subdepartment

  after_save :move_descendants_to_trash, :if => [:deleted_at_changed?, :deleted_at?]

  delegate :degree, :to => :speciality
  scope :actual, where(:deleted_at => nil)

  def warnings
    warnings = []
    warnings << "нет ООП" unless programm
    warnings << "нет УП" unless disciplines.actual.any?
    warnings
  end

  def move_descendants_to_trash
    disciplines.update_all(:deleted_at => Time.now)
    semesters.update_all(:deleted_at => Time.now)
  end

  def create_or_refresh_semester(number_str)
    number = number_str.to_i
    return nil unless number > 0
    semester = semesters.find_or_initialize_by_number(number)
    semester.deleted_at = nil
    semester.save!
    semester
  end
end
