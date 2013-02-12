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
  has_many :check_semesters, :class_name => 'Check', :through => :checks, :source => :semester

  scope :actual, where(:deleted_at => nil)

  validates_presence_of :title, :subspeciality, :subdepartment

  alias_attribute :deleted?, :deleted_at?

  after_save :move_descendants_to_trash, :if => [:deleted_at_changed?, :deleted_at?]

  delegate :speciality, :to => :subspeciality

  scope :consumed_by, ->(user) do
    if user.manager?
      subdepartment_ids = user.context_tree.flat_map(&:subdepartment_ids)
      select('DISTINCT(disciplines.id), disciplines.*').
        joins(:subspeciality).
        where('disciplines.subdepartment_id IN (?) OR subspecialities.subdepartment_id IN (?)', subdepartment_ids, subdepartment_ids).
        where('disciplines.deleted_at' => nil)
    elsif user.lecturer?
      where(:id => user.disciplines.actual)
    else
      where(:id => nil)
    end
  end

  scope :federal, where('specialities.cycle_code LIKE ?', '%.Ф')

  delegate :profiled_subdepartment, :graduated_subdepartment, :to => :subspeciality

  alias_method :provided_subdepartment, :subdepartment

  default_scope order('disciplines.cycle, disciplines.title')

  def move_descendants_to_trash
    checks.update_all(:deleted_at => Time.now)
    loadings.update_all(:deleted_at => Time.now)
  end

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

  def absolute_depth
    5
  end

  def esp_to_s
    "#{profiled_subdepartment.abbr} &mdash; #{esp_title}".html_safe
  end

  def esp_title
    "#{title} &mdash; #{subspeciality.speciality.code} &mdash; #{subspeciality.title} &mdash; #{profiled_subdepartment.department.year}".html_safe
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

