class Person < ActiveRecord::Base
  belongs_to :work_programm
  attr_accessible :academic_degree, :academic_rank, :full_name, :person_kind, :post, :short_name
  validates_presence_of :full_name, :post, :academic_degree, :academic_rank
  attr_accessor :short_name

  def self.nil
    @nil ||= Person.new(:full_name => '-'*10, :post => '-'*10, :short_name => '-'*10)
  end

  def self.collection_by_department(department)
    (JSON.parse(Requester.new("#{Settings['blue-pages.url']}/categories/#{department.context.id}.json").response_body)['items'] || []).map do |hash|
      Person.new :full_name => hash['person'],
        :post => hash['title'],
        :academic_degree => hash['academic_degree'],
        :academic_rank => hash['academic_rank']
    end
  end

  def as_json(*params)
    super(:except => [:id, :created_at, :updated_at, :work_programm_id, :person_kind, :full_name]).merge :value => full_name,
      :label => "#{full_name}, #{post.mb_chars.downcase}"
  end

  def short_name
    @short_name ||= "#{full_name.split(' ')[0]} #{full_name.split(' ')[1][0]}.#{full_name.split(' ')[2][0]}."
  end

end
