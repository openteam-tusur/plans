# encoding: utf-8

class WorkProgramm < ActiveRecord::Base
  attr_accessible :year, :purpose, :task

  belongs_to :discipline

  has_many :dependent_disciplines, :dependent => :destroy
  has_many :exercises,               :dependent => :destroy

  has_one :subspeciality, :through => :discipline

  delegate :previous_disciplines,   :to => :dependent_disciplines
  delegate :current_disciplines,    :to => :dependent_disciplines
  delegate :subsequent_disciplines, :to => :dependent_disciplines

  validates_presence_of :discipline, :year

  validates_uniqueness_of :year, :scope => :discipline_id

  delegate :subsequent_disciplines,
    :current_disciplines,
    :previous_disciplines,
    :to => :dependent_disciplines

  delegate :disciplines, :to => :subspeciality
  delegate :loaded_semesters, :to => :discipline

  default_value_for(:year) { Time.now.year }
  default_value_for(:task) { self.prepared_task_example }

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

  def available_previous_disciplines
    disciplines.select{ |d| d.semesters.map(&:number).max < discipline.semesters.map(&:number).min } - [discipline.title]
  end

  def available_current_disciplines
    disciplines.select{ |d| (d.semesters.map(&:number) & discipline.semesters.map(&:number)).any? } - [discipline.title]
  end

  def available_subsequent_disciplines
    disciplines.select{ |d| d.semesters.map(&:number).min > discipline.semesters.map(&:number).max } - [discipline.title]
  end

  def self.prepared_task_example
    <<-TEXTILE.gsub(/^ +/, '')
      # Первый пункт
      # Второй пункт
      # и т.д.

      По окончанию изучения дисциплины студент должен:
      * _иметь представление_
      * _знать_
      * _уметь_
      * _владеть_
    TEXTILE
  end

  def purpose_html
    RedCloth.new(purpose).to_html.html_safe if purpose?
  end

  def task_html
    RedCloth.new(task).to_html.html_safe if task?
  end

end
