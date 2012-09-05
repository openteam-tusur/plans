# encoding: utf-8

class WorkProgramm < ActiveRecord::Base
  attr_accessible :year, :purpose, :task, :related_discipline_ids, :generate, :vfs_path, :creator_id
  attr_accessor :generate, :message_text

  belongs_to :discipline
  belongs_to :creator, :class_name => User

  has_many :authors, :class_name => Person, :conditions => { :person_kind => 'author' }, :dependent => :destroy
  has_many :examination_questions,  :dependent => :destroy
  has_many :exercises,              :dependent => :destroy
  has_many :messages,               :dependent => :destroy
  has_many :missions,               :dependent => :destroy
  has_many :publications,           :dependent => :destroy
  has_many :rating_items,           :dependent => :destroy
  has_many :requirements,           :dependent => :destroy
  has_many :self_education_items,   :dependent => :destroy

  has_many :exercise_appendixes,            :through => :exercises,             :source => :appendix
  has_many :self_education_item_appendixes, :through => :self_education_items,  :source => :appendix

  has_one :subspeciality, :through => :discipline
  has_one :protocol, :dependent => :destroy

  has_and_belongs_to_many :related_disciplines, :class_name => Discipline

  validate :editable, :unless => :state_changed?
  validates_presence_of :discipline, :year
  validates_presence_of :vfs_path, :if => :gos3?
  validates_uniqueness_of :year, :scope => :discipline_id

  delegate :disciplines, :to => :subspeciality
  delegate :has_examinations?, :semesters, :semesters_with_examination, :to => :discipline
  delegate :speciality, :to => :subspeciality
  delegate :gos2?, :to => :speciality
  delegate :gos3?, :to => :speciality

  after_create :create_requirements
  after_create :create_protocol
  after_create :generate_work_programm, :if => ->(w) { w.generate.to_i == 1 }
  after_create :create_new_message

  default_value_for(:year) { Time.now.year }

  before_create :set_purpose

  scope :consumed_by, ->(user){ WorkProgramm.joins(:discipline).where(:disciplines => {:id => Discipline.consumed_by(user).map(&:id)}) }

  scope :drafts,                          ->(user){ with_state(:draft).where(:creator_id => user.id) }
  scope :reduxes,                         ->(user){ with_state(:redux).where(:creator_id => user.id) }
  scope :releases,                        ->(user){ consumed_by(user).with_state(:released) }
  scope :checks_by_provided_subdivision,  ->(user){ consumed_by(user).with_state(:check_by_provided_subdivision) }
  scope :checks_by_graduated_subdivision, ->(user){ consumed_by(user).with_state(:check_by_graduated_subdivision) }
  scope :checks_by_library,               ->(user){ consumed_by(user).with_state(:check_by_library) }
  scope :checks_by_methodological_office, ->(user){ consumed_by(user).with_state(:check_by_methodological_office) }
  scope :checks_by_educational_office,    ->(user){ consumed_by(user).with_state(:check_by_educational_office) }

  state_machine :initial => :draft do
    after_transition :move_messages_to_archive
    after_transition :create_new_message

    event :shift_up do
      transition :draft => :check_by_provided_subdivision,
                 :redux => :check_by_provided_subdivision,
                 :if => :whole_valid?

      transition :check_by_provided_subdivision => :check_by_graduated_subdivision,
                 :check_by_graduated_subdivision => :check_by_library,
                 :check_by_library => :check_by_methodological_office,
                 :check_by_methodological_office => :check_by_educational_office,
                 :check_by_educational_office => :released,
                 :if => :protocol_valid?
    end

    event :return_to_author do
      transition all - [:draft, :redux] => :redux
    end

    state :draft, :redux do
      def editable
        true
      end
    end

    state all - [:draft, :redux] do
      def editable
        errors.add(:base, 'Рабочая программа защищена от изменений и находится на проверке')
      end
    end
  end

  SRS_WEIGHTS = {
    :lecture => {
      :lecture => 0.3,
      :srs     => 0.2,
      :test    => 0.05,
    },
    :practice => {
      :practice => 0.4,
      :home_work => 0.2,
      :referat => 0.2,
      :colloquium => 0.3,
    },
    :exam => {
      :exam => 0.7,
      :individual_work => 0.3,
    },
    :lab => {
      :lab => 0.3,
      :calculation => 0.4,
    },
    :csr => {
      :csr => 0.7
    }
  }

  BRS_WEIGHTS = {
    :lecture => {
      :visiting => 4,
    },
    :practice => {
      :visiting  => 4,
      :practice  => 8,
    },
    :lab => {
      :visiting => 4,
      :lab      => 8,
    },
    :csr => {
      :visiting => 5,
      :intime   => 3,
      :csr      => 8
    },
    :exam => {
      :theoretical_question1 => 10,
      :theoretical_question2 => 10,
      :practic_question => 10
    }
  }

  PART_CLASSES = [Protocol, Person, Mission, Requirement, Exercise, SelfEducationItem,
                  Appendix, Publication, RatingItem, ExaminationQuestion]


  def appendixes
    @appendixes ||= exercise_appendixes + self_education_item_appendixes
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

  def move_messages_to_archive
    messages.each(&:read!)
  end

  def create_new_message
    messages.create!(:text => message_text)
  end

  # validate methods

  def protocol_valid?
    protocol.number?
  end

  def authors_valid?
    authors.any?
  end

  def purpose_valid?
    !!(purpose.squish != default_purpose && purpose =~ /[[:alnum:]]+/)
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

  def lectures_themes
    @lectures_themes ||= lectures.flat_map{|l| [l.title, l.description]}.delete_if(&:blank?).join(' ')
  end

  def didactic_unit_valid?(theme)
    lectures_themes.include? theme
  end

  def exercises_by_semester_and_kind_valid?(semester, kind)
    if kind.to_sym == :srs
      self_education_items_by_semester(semester).map(&:hours).sum == grouped_loadings(kind)[semester].first.value &&
        !self_education_items_by_semester(semester).map(&:item_valid?).include?(false)
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

  def publications_by_kind_valid?(kind)
    publications_by_kind(kind).any?
  end

  def publications_ump_valid?
    !ump_publication_kinds.map{ |kind| publications_by_kind_valid?("ump_#{kind}") }.include?(false)
  end

  def publications_valid?
    publications_by_kind_valid?(:basic) && publications_by_kind_valid?(:additional) && publications_ump_valid?
  end

  def brs_by_semester_valid?(semester)
    res = []
    res << rating_items_for_semester(semester).rating_item_kind_default.any?
    res << rating_items_for_semester(semester).rating_item_kind_csr.any? if grouped_loadings(:csr)[semester]
    res << examination_questions_for_semester(semester).any? if grouped_loadings(:exam)[semester]
    !res.include?(false)
  end

  def brs_valid?
    !discipline.semesters.map{ |semester| brs_by_semester_valid?(semester) }.include?(false)
  end

  def whole_valid?
    authors_valid? && purposes_and_missions_valid? && exercises_valid? && publications_valid? && brs_valid?
  end

  def as_json(*options)
    super(*options).merge :validations => { :whole_valid => whole_valid? }
                                            .merge(purposes_and_missions_json)
                                            .merge(exercises_json)
                                            .merge(publications_json)
                                            .merge(brs_json)
  end

  def to_s
    "Рабочая программа для дисциплины &laquo;#{discipline}&raquo; #{year} года набора".html_safe
  end

  private
    def purposes_and_missions_json
      {
        :protocol_valid => protocol_valid?,
        :authors_valid => authors_valid?,
        :purpose_valid => purpose_valid?,
        :missions_valid => missions_valid?,
        :related_disciplines_valid => related_disciplines_valid?,
        :purposes_and_missions_valid => purposes_and_missions_valid?
      }
    end

    def exercises_json
      json = { :exercises_valid => exercises_valid? }
      (Exercise.enum_values(:kind) + [:srs]).each do |kind|
        json[:"exercises_#{kind}_valid"] = exercises_by_kind_valid?(kind)
        grouped_loadings(kind).keys.each do |semester|
          json[:"exercises_#{kind}_#{semester.number}_valid"] = exercises_by_semester_and_kind_valid?(semester, kind)
        end
      end
      json
    end

    def publications_json
      json = {
        :publications_valid => publications_valid?,
        :publications_basic_valid => publications_by_kind_valid?(:basic),
        :publications_additional_valid => publications_by_kind_valid?(:additional),
        :publications_ump_valid => publications_ump_valid?,
      }
      ump_publication_kinds.each do |kind|
        json[:"publications_ump_#{kind}_valid"] = publications_by_kind_valid?("ump_#{kind}")
      end
      json
    end

    def brs_json
      json = { :brs_valid => brs_valid? }
      semesters.each do |semester|
        json[:"brs_#{semester.number}_valid"] = brs_by_semester_valid?(semester)
      end
      json
    end

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

    # Генерация рабочей программы
    def generate_work_programm
      generate_lectures
      generate_srs
      generate_brs
    end

    def generate_lectures
      if subspeciality.gos? && (didactic_unit = subspeciality.gos.didactic_units.find_by_discipline discipline.title)
        seed_lectures(didactic_unit)
      end
    end

    def seed_lectures(didactic_unit)
      loadings = grouped_loadings(:lecture)
      didactic_unit.lecture_themes(loadings.values.map(&:first).map(&:value)).each_with_index do |themes, index|
        semester = loadings.keys[index]
        loading = loadings[semester].first.value
        generate_lecture_hours(loading, themes).each do |title, hours|
          exercises.create! :semester_id => semester.id, :kind => :lecture, :title => title, :volume => hours
        end
      end
    end


    def generate_lecture_hours(total, lecture_themes)
      average = total / lecture_themes.count
      if average <= 1
        lecture_themes = merge_count(lecture_themes, total)
        average = total / lecture_themes.count
      end
      lecture_hours = []
      lecture_themes.each do |theme|
        lecture_hours << average
      end
      balancerirze(lecture_hours, total)
      lecture_themes.zip(lecture_hours)
    end

    def merge_count(lecture_themes, total)
      counter = lecture_themes.count / total + 1
      new_lecture_themes = []
      lecture_themes.each_slice(counter) do |lectures|
        new_lecture_themes << lectures.join('; ')
      end
      new_lecture_themes
    end

    def generate_srs
      genereated_srs = {}
      semesters = grouped_loadings(:srs).keys
      semesters.each do |semester|
        srs_loading_volume = semester.loadings.where(:discipline_id => discipline).where(:loading_kind => :srs).first.value

        loading_kinds = (semester.loadings.where(:discipline_id => discipline).map(&:loading_kind).map(&:to_sym) & SRS_WEIGHTS.keys)

        temp = {}
        loading_kinds.each do |kind|
          SRS_WEIGHTS[kind].each do |srs_kind, weight|
            temp[srs_kind] = calculate_volume(weight, grouped_loadings(kind)[semester].first.value)
          end
        end

        genereated_srs[semester] = temp

        if (genereated_srs[semester].values.sum - srs_loading_volume) != 0
          values = genereated_srs[semester].values
          balancerirze(values, srs_loading_volume)
          genereated_srs[semester] = Hash[genereated_srs[semester].keys.zip(values)]
        end
      end

      create_srs(genereated_srs)
    end

    def generate_brs
      discipline.loadings.where(:loading_kind => [:lecture, :practice, :lab, :csr, :exam]).each do |loading|
        BRS_WEIGHTS[loading.loading_kind.to_sym].each do |brs_kind, score|
          if loading.loading_kind_exam?
            examination_questions.create! :semester_id => loading.semester.id,
                                          :question_kind => WorkProgramm.human_attribute_name("#{loading.loading_kind}_#{brs_kind}"),
                                          :score => score

          else
            rating_items.create! :semester_id => loading.semester.id,
              :title => WorkProgramm.human_attribute_name("#{loading.loading_kind}_#{brs_kind}"),
              :max_begin_1kt => score,
              :max_1kt_2kt => score,
              :max_2kt_end => score,
              :rating_item_kind => loading.loading_kind_csr? ? :csr : :default
          end
        end
      end
      discipline.loadings.where(:loading_kind => [:lecture, :practice, :lab]).pluck('DISTINCT semester_id').each do |semester_id|
        rating_items.create! :semester_id => semester_id,
          :title =>  WorkProgramm.human_attribute_name("intime"),
          :max_begin_1kt => 4,
          :max_1kt_2kt => 4,
          :max_2kt_end => 4,
          :rating_item_kind => :default
      end
    end

    def balancerirze(values, total)
      while (difference = (values.sum - total)).abs != 0 do
        index = Random.rand(values.count)
        values[index] += (0 <=> difference)
        values[index] = 1 if values[index].zero?
      end
      values
    end

    def create_srs(srs)
      srs.each do |semester, items|
        items.each do |kind, hours|
          self_education_items.create(
            :semester_id => semester.id,
            :kind => kind,
            :hours => hours,
            :control => SelfEducationItem::AVAILABLE_CONTROLS[kind].sample
          )
        end
      end
    end

    def calculate_volume(weight, total_volume)
      (total_volume * weight).round
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
#  vfs_path      :string(255)
#

