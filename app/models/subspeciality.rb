class Subspeciality < ActiveRecord::Base
  belongs_to :speciality
  attr_accessible :name
end
#--
# generated by 'annotated-rails' gem, please do not remove this line and content below, instead use `bundle exec annotate-rails -d` command
#++
# Table name: subspecialities
#
# * id            :integer         not null
#   name          :string(255)
#   speciality_id :integer
#   created_at    :datetime        not null
#   updated_at    :datetime        not null
#
#  Indexes:
#   index_subspecialities_on_speciality_id  speciality_id
#--
# generated by 'annotated-rails' gem, please do not remove this line and content above, instead use `bundle exec annotate-rails -d` command
#++
