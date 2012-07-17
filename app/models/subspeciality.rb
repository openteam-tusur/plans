# encoding: utf-8

class Subspeciality < ActiveRecord::Base
  attr_accessible :title, :subdepartment_id

  alias_attribute :deleted?, :deleted_at?

  belongs_to :speciality
  belongs_to :subdepartment

  has_one :programm, :as => :with_programm
  has_many :disciplines, :dependent => :destroy

  validates_presence_of :title, :speciality, :subdepartment

  after_save :move_disciplines_to_trash, :if => [:deleted_at_changed?, :deleted_at?]

  delegate :degree, :to => :speciality
  scope :actual, where(:deleted_at => nil)

  def warnings
    warnings = []
    warnings << "нет ООП" unless programm
    warnings << "нет УП" unless disciplines.actual.any?
    warnings
  end


  def move_disciplines_to_trash
    disciplines.update_all(:deleted_at => Time.now)
  end
end
#--
# generated by 'annotated-rails' gem, please do not remove this line and content below, instead use `bundle exec annotate-rails -d` command
#++
# Table name: subspecialities
#
# * id               :integer         not null
#   title            :string(255)
#   speciality_id    :integer
#   subdepartment_id :integer
#   deleted_at       :datetime
#   created_at       :datetime        not null
#   updated_at       :datetime        not null
#
#  Indexes:
#   index_subspecialities_on_speciality_id  speciality_id
#--
# generated by 'annotated-rails' gem, please do not remove this line and content above, instead use `bundle exec annotate-rails -d` command
#++
