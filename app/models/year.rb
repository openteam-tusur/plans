class Year < ActiveRecord::Base
  attr_accessible :number

  has_many :departments

  validates_presence_of :number
end
#--
# generated by 'annotated-rails' gem, please do not remove this line and content below, instead use `bundle exec annotate-rails -d` command
#++
# Table name: years
#
# * id         :integer         not null
#   number     :integer
#   created_at :datetime        not null
#   updated_at :datetime        not null
#--
# generated by 'annotated-rails' gem, please do not remove this line and content above, instead use `bundle exec annotate-rails -d` command
#++
