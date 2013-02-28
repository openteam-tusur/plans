# encoding: utf-8

class Discipline < ActiveRecord::Base
  attr_accessible :title

  belongs_to :subspeciality
  belongs_to :subdepartment

  has_one :speciality, :through => :subspeciality
  has_many :checks, :dependent => :destroy
  has_many :loadings, :dependent => :destroy
  has_many :work_programms, :dependent => :destroy
  has_many :semesters, :through => :loadings, :uniq => true

  scope :actual, where(:deleted_at => nil)

  validates_presence_of :title, :subspeciality, :subdepartment

  alias_attribute :deleted?, :deleted_at?

  delegate :speciality, :to => :subspeciality

  # TODO: only permitted for non managers
  scope :consumed_by, ->(user) do
    scoped
  end

  scope :federal, where('specialities.cycle_code LIKE ?', '%.Ф')

  scope :subdepartment_abbr, ->(abbr) { joins(:subdepartment).where(:subdepartments => {:abbr => abbr}) }

  delegate :profiled_subdepartment, :graduated_subdepartment, :to => :subspeciality

  alias_method :provided_subdepartment, :subdepartment

  def to_s
    title
  end

  def translited_cycle
    I18n.transliterate(cycle).downcase.gsub(/[^[:alnum:]]+/, '_')
  end

  def semesters_with_examination
    checks.where(check_kind: 'exam').map(&:semester)
  end

  def has_examinations?
    semesters_with_examination.any?
  end

  def has_exam_at_semester?(semester)
    semesters_with_examination.include? semester
  end

  def federal?
    cycle_code.split('.').try(:second) == 'Ф'
  end

  def <=>(other)
    title <=> other.title
  end

  def subdepartment_ids
  end

  def didactic_unit
    @didactic_unit ||= DidacticUnit.joins(:gos).where('goses.speciality_code = ? AND didactic_units.discipline = ?', speciality.code, title).first
  end
end

# == Schema Information
#
# Table name: disciplines
#
#  id               :integer          not null, primary key
#  title            :string(255)
#  cycle            :string(255)
#  subspeciality_id :integer
#  subdepartment_id :integer
#  deleted_at       :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  summ_loading     :integer
#  summ_srs         :integer
#  cycle_code       :string(255)
#

