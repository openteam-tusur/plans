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
  attr_accessible :title, :identifier, :credit_units, :subdepartment_id

  belongs_to :subspeciality
  belongs_to :subdepartment

  has_one :speciality, :through => :subspeciality
  has_many :checks, :dependent => :destroy, :order => 'checks.kind'
  has_many :loadings, :dependent => :destroy, :order => 'loadings.kind'
  has_many :work_programms, :dependent => :destroy
  has_many :semesters, :through => :loadings, :uniq => true
  has_many :check_semesters, :through => :checks, :uniq => true, :source => :semester

  has_many :methodologists, :through => :subdepartment

  has_and_belongs_to_many :competences

  scope :actual, where(:deleted_at => nil)
  scope :special_work, where(:special_work => true)
  scope :without_special_work, where('special_work != ?', true)

  validates_presence_of :title, :subspeciality, :subdepartment

  serialize :credit_units, Hash

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

  def loadings_in_semester(semester)
    loadings.select{|l| l.semester_id == semester.id}
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

  def semesters_info
    res = {}

    return optionally_with_credit_units_and_semesters.first.semesters_info if semesters.empty? && has_optionally_disciplines?

    semesters.each do |semester|
      res[semester.number] = {
        :checks => checks_in_semester(semester).map(&:kind),
        :loadings => loadings_in_semester(semester).map{|l| { l.kind => l.value }},
        :credit_units => credit_units[semester.number.to_s]
      }
    end

    if res.empty?
      res[subspeciality.semesters.last.number] = {}
    end
    res
  end

  def provided_info
    s = subdepartment.presence || subspeciality.subdepartment
    {
      :subdepartment => DepartmentsData.instance.subdepartment_data(s),
      :department    => DepartmentsData.instance.department_data(s.department)
    }
  end

  def identifier_prefix
    identifier.split('.')[0..-2].join('.')
  end

  def has_optionally_disciplines?
    return false unless identifier?

    identifier.split('.').length > 4
  end

  def optionally_disciplines
    return [] unless has_optionally_disciplines?

    subspeciality.disciplines.where('disciplines.id != :id AND identifier LIKE :identifier_prefix', :id => id, :identifier_prefix => "#{identifier_prefix}%")
  end

  def optionally_disciplines_with_credit_units
    return [] unless has_optionally_disciplines?
    optionally_disciplines.where("credit_units not like '%{}%'")
  end

  def optionally_with_credit_units_and_semesters
    optionally_disciplines_with_credit_units.joins(:semesters).uniq
  end

  def optionally_disciplines_with_empty_credit_units
    return [] unless has_optionally_disciplines?
    optionally_disciplines.where("credit_units like '%{}%'")
  end

  def subdepartment
    h = DepartmentsData.instance.abolished_departments
    return subspeciality.subdepartment unless super
    h[super.abbr] ? Subdepartment.find_by_abbr(h[super.abbr]) : super
  end
end
