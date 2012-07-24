# encoding: utf-8

class TitlePage::Scheduling
  class Row
    attr_accessor :scheduling, :hours, :loading_kind, :title

    delegate :discipline, :to => :scheduling

    def initialize(options)
      options.each do |key, value|
        self.send "#{key}=", value
      end
    end

    def hours
      @hours ||= discipline.loadings.where(:loading_kind => loading_kind).inject({}) do |hash, loading|
        hash[loading.semester.number] ||= 0
        hash[loading.semester.number] += loading.value
        hash
      end
    end

    def total
      hours.values.sum
    end

    def title
      @title ||= Loading.human_enum_values(:loading_kind)[loading_kind]
    end

    def to_a
      [title, total].tap do |arr|
        if scheduling.loaded_semesters.count > 1
          scheduling.loaded_semesters.each do |semester|
            arr << (hours[semester] || '-')
          end
        end
      end
    end
  end

  attr_accessor :report, :discipline

  delegate :loaded_semesters, :to => :report

  def initialize(report, discipline)
    self.report = report
    self.discipline = discipline
  end

  Loading.enum_values(:loading_kind).each do |kind|
    define_method "#{kind}" do
      Row.new(:scheduling => self, :loading_kind => kind)
    end
  end

  alias_method :old_exam, :exam

  def exam
    if discipline.summ_loading == total.total
      old_exam
    else
      Row.new(:scheduling => self, :loading_kind => 'exam', :hours => {})
    end
  end

  def classroom
    Row.new(:scheduling => self, :loading_kind => Loading.classroom_kinds, :title => 'Всего аудиторных занятий')
  end

  def total
    Row.new(:scheduling => self, :loading_kind => Loading.enum_values(:loading_kind), :title => 'Общая трудоемкость')
  end

  def header
    if loaded_semesters.count > 1
      [
        [{:content => "", :rowspan=> 2}, {:content => "Всего часов", :rowspan => 2}, {:content => "По семестрам", :colspan => loaded_semesters.size}],
        loaded_semesters.map { |number| "#{number}" }
      ]
    else
      [["", "Всего часов"]]
    end
  end

  def to_a
    result = header

    (Loading.classroom_kinds + ['classroom'] + Loading.srs_kinds + ['total']).each do |name|
      row = self.send(name)
      result << row.to_a unless row.total.zero?
    end
    result
  end
end
