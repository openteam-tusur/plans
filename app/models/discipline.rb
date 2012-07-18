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
end
#--
# generated by 'annotated-rails' gem, please do not remove this line and content below, instead use `bundle exec annotate-rails -d` command
#++
# Table name: disciplines
#
# * id               :integer         not null
#   title            :string(255)
#   cycle            :string(255)
#   subspeciality_id :integer
#   subdepartment_id :integer
#   deleted_at       :datetime
#   created_at       :datetime        not null
#   updated_at       :datetime        not null
#
#  Indexes:
#   index_disciplines_on_subdepartment_id  subdepartment_id
#   index_disciplines_on_subspeciality_id  subspeciality_id
#--
# generated by 'annotated-rails' gem, please do not remove this line and content above, instead use `bundle exec annotate-rails -d` command
#++
