# encoding: utf-8

class WorkProgramm < ActiveRecord::Base
  attr_accessible :year, :purpose, :task, :related_discipline_ids

  belongs_to :discipline

  has_many :examination_questions,  :dependent => :destroy
  has_many :exercises,              :dependent => :destroy
  has_many :missions,               :dependent => :destroy
  has_many :publications,           :dependent => :destroy
  has_many :rating_items,           :dependent => :destroy
  has_many :requirements,           :dependent => :destroy
  has_many :self_education_items,   :dependent => :destroy

  has_many :exercise_appendixes,            :through => :exercises,             :source => :appendix
  has_many :self_education_item_appendixes, :through => :self_education_items,  :source => :appendix

  has_one :subspeciality, :through => :discipline


  has_and_belongs_to_many :related_disciplines, :class_name => Discipline

  validates_presence_of :discipline, :year

  validates_uniqueness_of :year, :scope => :discipline_id

  delegate :disciplines, :to => :subspeciality
  delegate :has_examinations?, :semesters, :semesters_with_examination, :to => :discipline

  after_create :create_requirements

  default_value_for(:year) { Time.now.year }

  before_create :set_purpose

  def appendixes
    @appendixes ||= exercise_appendixes + self_education_item_appendixes
  end

  # FIXME: пока просто заглушка
  def authors
    [
      Person.new(:name => "Сидоров Анатолий Анатольевич", :post => "Доцент каф. АОИ", :science_post => "канд. экон. наук"),
      Person.new(:name => "Ехлаков Юрий Поликарпович", :post => "Зав. кафедрой АОИ", :science_post => "д-р техн. наук, профессор")
    ]
  end

  def self_education_items_by_semester(semester)
    self_education_items.where(:semester_id => semester)
  end

  Exercise.enums['kind'].each do |kind|
    define_method kind.pluralize do
      exercises.where(:kind => kind)
    end
  end

  def exercises_by_semester_and_kind(semester, kind)
    send(kind.pluralize).where(:semester_id => semester)
  end

  def previous_disciplines
    related_disciplines.select{ |d| d.semesters.map(&:number).max < discipline.semesters.map(&:number).min } - [discipline.title]
  end

  def current_disciplines
    related_disciplines.select{ |d| (d.semesters.map(&:number) & discipline.semesters.map(&:number)).any? } - [discipline.title]
  end

  def subsequent_disciplines
    related_disciplines.select{ |d| d.semesters.map(&:number).min > discipline.semesters.map(&:number).max } - [discipline.title]
  end

  def available_exercise_kinds
    res = []
    res = discipline.loadings.pluck(:loading_kind) & Exercise.enum_values(:kind)
    res << 'srs' if discipline.loadings.pluck(:loading_kind).include?('srs')
    res
  end

  def ump_publication_kinds
    available_exercise_kinds - ['lecture']
  end

  def publications_by_kind(kind)
    publications.where publication_kind: kind
  end

  def has_loadings_for?(kind)
    discipline.loadings.where(loading_kind: kind).any? || SelfEducationItem::FIFTH_ITEM_KINDS.include?(kind)
  end

  def grouped_loadings(kind)
    Hash[discipline.loadings.where(:loading_kind => kind).group_by(&:semester).sort{|a,b| a[0].number <=> b[0].number}]
  end

  def rating_items_for_semester(semester)
    rating_items.where(semester_id: semester)
  end

  def examination_questions_for_semester(semester)
    examination_questions.where(semester_id: semester)
  end

  # validate methods

  def purpose_valid?
    purpose =~ /#{default_purpose} .*[[:alnum:]]+/
  end

  def missions_valid?
    missions.any? && requirements.select(&:description?).count == 3
  end

  def related_disciplines_valid?
    related_disciplines.any?
  end

  def purposes_and_missions_valid?
    purpose_valid? && missions_valid? && related_disciplines_valid?
  end

  def exercises_by_semester_and_kind_valid?(semester, kind)
    if kind.to_sym == :srs
      self_education_items_by_semester(semester).map(&:hours).sum == grouped_loadings(kind)[semester].first.value
    else
      exercises_by_semester_and_kind(semester, kind).map(&:volume).sum == grouped_loadings(kind)[semester].first.value
    end
  end

  def exercises_by_kind_valid?(kind)
    !grouped_loadings(kind).keys.map{ |semester| exercises_by_semester_and_kind_valid?(semester, kind) }.include?(false)
  end

  def self_education_items_by_semester_valid?(semester)
    exercises_by_semester_and_kind_valid?(semester, :srs)
  end

  def exercises_valid?
    !(Exercise.enum_values(:kind) + [:srs]).map{|kind| exercises_by_kind_valid?(kind) }.include?(false)
  end

  private
    def default_purpose
      "Целью изучения дисциплины «#{discipline.title}» является"
    end

    def set_purpose
      self.purpose = default_purpose
    end

    def create_requirements
      Requirement.enums['requirement_kind'].each do |kind|
        requirements.create(requirement_kind: kind)
      end
    end
end

# == Schema Information
#
# Table name: work_programms
#
#  id            :integer          not null, primary key
#  year          :integer
#  discipline_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  purpose       :text
#

