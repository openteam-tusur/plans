# encoding: utf-8

class Discipline < ActiveRecord::Base
  attr_accessible :title

  belongs_to :subspeciality
  belongs_to :subdepartment

  has_one :programm, :as => :with_programm
  has_many :checks, :dependent => :destroy
  has_many :loadings, :dependent => :destroy
  has_many :work_programms, :dependent => :destroy

  scope :actual, where(:deleted_at => nil)

  validates_presence_of :title, :subspeciality, :subdepartment

  alias_attribute :deleted?, :deleted_at?

  after_save :move_descendants_to_trash, :if => [:deleted_at_changed?, :deleted_at?]

  def move_descendants_to_trash
    checks.update_all(:deleted_at => Time.now)
    loadings.update_all(:deleted_at => Time.now)
  end

  def loaded_courses
    loaded_semester_numbers.map { |s| (s.to_f / 2).round }.uniq
  end

  def loaded_semesters
    loadings.map(&:semester).uniq.sort_by(&:number)
  end

  def loaded_semester_numbers
    loaded_semesters.map(&:number)
  end

  def taught_in_one_semester?
    loaded_semesters.one?
  end

  def calculated_classroom_loading_summ
    loadings.where(:loading_kind => Loading.classroom_kinds).sum(&:value)
  end

  def calculated_classroom_loading_summ_for_semester(semester_number)
    loadings.where(:loading_kind => Loading.classroom_kinds, :semester_id => subspeciality.semesters.where(:number => semester_number).first).sum(&:value)
  end

  def calculated_loading_summ
    loadings.sum(&:value)
  end

  def calculated_loading_summ_for_semester(semester_number)
    uses_loading_kinds = Loading.enum_values(:loading_kind)
    uses_loading_kinds.delete('exam') if calculated_loading_summ > summ_loading
    loadings.where(:loading_kind => uses_loading_kinds, :semester_id => subspeciality.semesters.where(:number => semester_number).first).sum(&:value)
  end

  def semesters
    loadings.map(&:semester).uniq
  end

  COMPONENT_ABBR = {
    'Ф' => 'федеральный',
    'Р' => 'региональный',
    'В' => 'выборный'
  }

  def decoded_component
    COMPONENT_ABBR[component[0]] || raise("не могу расшифровать компонент '#{component}'")
  end
end
