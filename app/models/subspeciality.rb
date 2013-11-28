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
#  reduced                    :string(255)
#


class Subspeciality < ActiveRecord::Base

  attr_accessible :title, :subdepartment_id, :graduated_subdepartment_id, :education_form, :department_id, :plan_digest, :file_path, :reduced

  alias_attribute :deleted?, :deleted_at?

  belongs_to :speciality
  belongs_to :subdepartment
  belongs_to :graduated_subdepartment, :class_name => 'Subdepartment'
  belongs_to :department

  has_one :programm
  has_one :work_plan
  has_many :disciplines, :dependent => :destroy, :order => :title
  has_many :checks, :through => :disciplines
  has_many :loadings, :through => :disciplines
  has_many :actual_disciplines, :class_name => 'Discipline', :conditions => { :deleted_at => nil }
  has_many :semesters, :dependent => :destroy
  has_many :actual_semesters, :class_name => 'Semester', :conditions => { :deleted_at => nil }
  has_one :year, :through => :speciality
  has_many :competences, :dependent => :destroy

  validates_presence_of :title, :speciality, :subdepartment, :department, :education_form

  validates_uniqueness_of :title, :scope => [:speciality_id, :subdepartment_id, :education_form, :reduced]

  delegate :degree, :gos_generation, :to => :speciality
  delegate :code, :title, to: :speciality, prefix: true
  delegate :abbr, :title, :to => :department, :prefix => true
  delegate :abbr, :title, :to => :subdepartment, :prefix => true
  scope :actual, where(:deleted_at => nil)

  alias_method :profiled_subdepartment, :subdepartment

  extend Enumerize
  enumerize :education_form, :in => %w[full-time part-time postal postal-with-dist], :scope => true
  enumerize :reduced,        :in => %w[higher_specialized higher_unspecialized secondary_specialized secondary_unspecialized]

  # TODO: only permitted for non managers
  scope :consumed_by, ->(user) do
    scoped
  end

  scope :ordered, -> do
    joins(:year)
    .joins(:subdepartment)
    .order('years.number',
           'specialities.code',
           'subspecialities.title',
           'subdepartments.abbr',
           'subspecialities.education_form',
           'subspecialities.reduced desc')
  end

  scope :ordered_by_year_desc, -> do
    joins(:year).order('years.number desc')
  end

  scope :with_degree, ->(degree) do
    joins(:speciality).
      where(:specialities => {:degree => degree})
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

  def to_s
    "#{title}, #{education_form_text} форма"
  end

  def import_to_s
    "#{year.number} / #{speciality.code} / '#{title}' #{education_form} #{reduced}"
  end

  def postal?
    !!(education_form =~ /^postal/)
  end

  def graduated_info
    {
      :department => DepartmentsData.instance.department_data(graduated_subdepartment.department),
      :subdepartment => DepartmentsData.instance.subdepartment_data(graduated_subdepartment)
    }
  end

  def profiled_info
    {
      :department => DepartmentsData.instance.department_data(subdepartment.department),
      :subdepartment => DepartmentsData.instance.subdepartment_data(subdepartment),
    }
  end
end
