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

  scope :consumed_by, ->(user) do
    subdepartment_ids = user.context_tree.flat_map(&:subdepartment_ids)
    select('DISTINCT(subspecialities.id), subspecialities.*').
      joins(:disciplines).
      where('disciplines.subdepartment_id IN (?) OR subspecialities.subdepartment_id IN (?)', subdepartment_ids, subdepartment_ids)
  end

  delegate :gos, :gos?, :to => :speciality
  delegate :consumed_by, :to => :disciplines, :prefix => true

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

# == Schema Information
#
# Table name: subspecialities
#
#  id                        :integer          not null, primary key
#  title                     :string(255)
#  speciality_id             :integer
#  subdepartment_id          :integer
#  deleted_at                :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  graduate_subdepartment_id :integer
#

