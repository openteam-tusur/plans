# encoding: utf-8
# == Schema Information
#
# Table name: subspecialities
#
#  id                         :integer          not null, primary key
#  title                      :string(255)
#  speciality_id              :integer
#  subdepartment_id           :integer
#  deleted_at                 :datetime
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  graduated_subdepartment_id :integer
#  department_id              :integer
#  education_form             :string(255)
#  file_path                  :text
#  plan_digest                :string(255)
#


class Subspeciality < ActiveRecord::Base
  attr_accessible :title, :subdepartment_id, :graduated_subdepartment_id, :education_form, :department_id, :plan_digest, :file_path

  alias_attribute :deleted?, :deleted_at?

  belongs_to :speciality
  belongs_to :subdepartment
  belongs_to :graduated_subdepartment, :class_name => 'Subdepartment'
  belongs_to :department

  has_one :programm
  has_one :work_plan
  has_many :disciplines, :dependent => :destroy
  has_many :checks, :through => :disciplines
  has_many :loadings, :through => :disciplines
  has_many :actual_disciplines, :class_name => 'Discipline', :conditions => { :deleted_at => nil }
  has_many :semesters, :dependent => :destroy

  validates_presence_of :title, :speciality, :subdepartment, :department, :education_form

  after_save :move_descendants_to_trash, :if => [:deleted_at_changed?, :deleted_at?]

  default_scope order('subspecialities.title')

  delegate :degree, :to => :speciality
  scope :actual, where(:deleted_at => nil)

  alias_method :profiled_subdepartment, :subdepartment

  has_enum :education_form

  scope :consumed_by, ->(user) do
    if user.manager?
      subdepartment_ids = user.context_tree.flat_map(&:subdepartment_ids)
      select('DISTINCT(subspecialities.id), subspecialities.*').
        joins('LEFT OUTER JOIN disciplines ON disciplines.subspeciality_id = subspecialities.id').
        where('disciplines.subdepartment_id IN (?) OR subspecialities.subdepartment_id IN (?)', subdepartment_ids, subdepartment_ids)
    elsif user.lecturer?
      joins(:disciplines).where(:disciplines => {:id => user.context_tree.select{|c| c.is_a?(Discipline)}})
    else
      where(:id => nil)
    end
  end

  delegate :gos, :gos?, :to => :speciality
  delegate :consumed_by, :to => :disciplines, :prefix => true

  def has_actual_disciplines?
    actual_disciplines.length > 0
  end

  def warnings
    warnings = []
    warnings << "нет ООП" unless programm
    warnings << "нет РУП" unless work_plan
    warnings << "нет УП" unless has_actual_disciplines?
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

  def to_s
    "#{title}, #{human_education_form}"
  end
end
