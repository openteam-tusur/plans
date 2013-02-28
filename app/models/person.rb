class Person < ActiveRecord::Base
  belongs_to :work_programm
  attr_accessible :academic_degree, :academic_rank, :full_name, :person_kind, :post, :short_name
  validates_presence_of :full_name, :post
  validates_uniqueness_of :full_name, :academic_degree, :academic_rank, :post, :scope => :work_programm_id
  attr_accessor :short_name

  def self.nil
    @nil ||= Person.new(:full_name => '-'*10, :post => '-'*10, :short_name => '-'*10)
  end

  # TODO выпилить
  def self.chief_of(department)
    Person.nil
  end

  # TODO выпилить
  def self.collection_by_department(department)
    []
  end

  def as_json(*params)
    super(:except => [:id, :created_at, :updated_at, :work_programm_id, :person_kind, :full_name]).merge :value => full_name,
      :label => "#{full_name}, #{post.mb_chars.downcase}"
  end

  def short_name
    @short_name ||= "#{full_name.split(' ')[0]} #{full_name.split(' ')[1][0]}.#{full_name.split(' ')[2][0]}."
  end

  def to_a
    ["#{post}\n#{[academic_degree, academic_rank].select(&:present?).join(', ').mb_chars.downcase}", "______________", short_name]
  end

end

# == Schema Information
#
# Table name: people
#
#  id               :integer          not null, primary key
#  academic_degree  :text
#  academic_rank    :text
#  post             :text
#  full_name        :text
#  work_programm_id :integer
#  person_kind      :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

