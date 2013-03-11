# encoding: utf-8
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
#  cycle_id         :string(255)
#  kind             :string(255)
#


class Discipline < ActiveRecord::Base
  attr_accessible :title

  belongs_to :subspeciality
  belongs_to :subdepartment

  has_one :speciality, :through => :subspeciality
  has_many :checks, :dependent => :destroy, :order => 'checks.kind'
  has_many :loadings, :dependent => :destroy, :order => 'loadings.kind'
  has_many :work_programms, :dependent => :destroy
  has_many :semesters, :through => :loadings, :uniq => true
  has_many :check_semesters, :through => :checks, :uniq => true, :source => :semester

  has_many :methodologists, :through => :subdepartment

  scope :actual, where(:deleted_at => nil)

  validates_presence_of :title, :subspeciality, :subdepartment

  alias_attribute :deleted?, :deleted_at?

  delegate :speciality, :to => :subspeciality

  scope :consumed_by, ->(user) { joins(:subdepartment).merge(Subdepartment.consumed_by(user)) }

  scope :federal, where('specialities.cycle_code LIKE ?', '%.Ф')

  scope :subdepartment_abbr, ->(abbr) { joins(:subdepartment).where(:subdepartments => {:abbr => abbr}) }

  scope :ordered, -> { order('disciplines.cycle_id, disciplines.title') }

  delegate :profiled_subdepartment, :graduated_subdepartment, :to => :subspeciality

  alias_method :provided_subdepartment, :subdepartment

  extend Enumerize
  enumerize :kind, :in => %w[common meta]

  def all_semesters
    semesters + check_semesters
  end

  def semester_numbers
    @semester_numbers ||= all_semesters.map(&:number).uniq
  end

  def classroom_loadings_in_semester(semester)
    loadings.select(&:classroom?).select{|l| l.semester_id == semester.id}
  end

  def checks_in_semester(semester)
    checks.select{|c| c.semester_id == semester.id}
  end

  def to_s
    title
  end

  def translited_cycle
    I18n.transliterate(cycle).downcase.gsub(/[^[:alnum:]]+/, '_')
  end

  def semesters_with_examination
    checks.with_kind('exam').map(&:semester)
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
