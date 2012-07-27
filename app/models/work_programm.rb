# encoding: utf-8

class WorkProgramm < ActiveRecord::Base
  attr_accessible :year, :purpose, :task, :related_discipline_ids

  belongs_to :discipline

  has_many :exercises,              :dependent => :destroy
  has_many :missions,               :dependent => :destroy
  has_many :requirements,           :dependent => :destroy

  has_one :subspeciality, :through => :discipline

  has_and_belongs_to_many :related_disciplines, :class_name => Discipline

  validates_presence_of :discipline, :year

  validates_uniqueness_of :year, :scope => :discipline_id

  delegate :disciplines, :to => :subspeciality
  delegate :loaded_semesters, :to => :discipline

  after_create :create_requirements

  default_value_for(:year) { Time.now.year }

  before_create :set_purpose

  # FIXME: пока просто заглушка
  def authors
    [
      Person.new(:name => "Сидоров Анатолий Анатольевич", :post => "Доцент каф. АОИ", :science_post => "канд. экон. наук"),
      Person.new(:name => "Ехлаков Юрий Поликарпович", :post => "Зав. кафедрой АОИ", :science_post => "д-р техн. наук, профессор")
    ]
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

  private
  def set_purpose
    self.purpose = "Целью изучения дисциплины «#{discipline.title}» является"
  end

  def create_requirements
    Requirement.enums['requirement_kind'].each do |kind|
      requirements.create(:requirement_kind => kind)
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
#  task          :text
#

