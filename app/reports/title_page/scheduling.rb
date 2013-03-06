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
      @title ||= Loading.loading_kind.find_value(loading_kind).text
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

  CLASSROOM_KINDS = %w[lecture lab practice csr]
  ALL_KINDS       = %w[lecture lab practice csr classroom srs exam total]

  Loading.loading_kind.values.each do |kind|
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
    Row.new(:scheduling => self, :loading_kind => CLASSROOM_KINDS, :title => 'Всего аудиторных занятий')
  end

  def total
    Row.new(:scheduling => self, :loading_kind => Loading.loading_kind.values, :title => 'Общая трудоемкость')
  end

  def header
    if loaded_semesters.count > 1
      [
        [{:content => "", :rowspan=> 2}, {:content => "Всего часов", :rowspan => 2}, {:content => "По семестрам", :colspan => loaded_semesters.size}],
        loaded_semesters.map { |number| { :content => "#{number}" } }
      ]
    else
      [
        [{:content => ""}, {:content => "Всего часов"}]
      ]
    end
  end


  def to_a
    result = []
    ALL_KINDS.each do |name|
      row = self.send(name)
      result << row.to_a unless row.total.zero?
    end
    result
  end
end
