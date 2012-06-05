class Subspeciality < ActiveRecord::Base
  attr_accessible :title

  belongs_to :speciality
  belongs_to :graduator, :polymorphic => true

  has_one :programm
  has_many :disciplines, :dependent => :destroy

  validates_presence_of :title, :speciality, :graduator
end
#--
# generated by 'annotated-rails' gem, please do not remove this line and content below, instead use `bundle exec annotate-rails -d` command
#++
# Table name: subspecialities
#
# * id             :integer         not null
#   title          :string(255)
#   speciality_id  :integer
#   graduator_id   :integer
#   graduator_type :string(255)
#   created_at     :datetime        not null
#   updated_at     :datetime        not null
#
#  Indexes:
#   index_subspecialities_on_speciality_id  speciality_id
#--
# generated by 'annotated-rails' gem, please do not remove this line and content above, instead use `bundle exec annotate-rails -d` command
#++
