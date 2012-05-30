class Programm < ActiveRecord::Base
  belongs_to :year
  belongs_to :subdepartment
  belongs_to :speciality
  # attr_accessible :title, :body
end
#--
# generated by 'annotated-rails' gem, please do not remove this line and content below, instead use `bundle exec annotate-rails -d` command
#++
# Table name: programms
#
# * id               :integer         not null
#   year_id          :integer
#   subdepartment_id :integer
#   speciality_id    :integer
#   speciality_type  :string(255)
#   created_at       :datetime        not null
#   updated_at       :datetime        not null
#
#  Indexes:
#   index_programms_on_speciality_type   speciality_type
#   index_programms_on_speciality_id     speciality_id
#   index_programms_on_subdepartment_id  subdepartment_id
#   index_programms_on_year_id           year_id
#--
# generated by 'annotated-rails' gem, please do not remove this line and content above, instead use `bundle exec annotate-rails -d` command
#++
