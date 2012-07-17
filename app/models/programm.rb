# encoding: utf-8

class Programm < ActiveRecord::Base
  attr_accessible :description, :vfs_path
  belongs_to :with_programm, :polymorphic => true
  validates_presence_of :description, :vfs_path, :with_programm
end
#--
# generated by 'annotated-rails' gem, please do not remove this line and content below, instead use `bundle exec annotate-rails -d` command
#++
# Table name: programms
#
# * id                 :integer         not null
#   with_programm_id   :integer
#   with_programm_type :string(255)
#   description        :text
#   vfs_path           :string(255)
#   created_at         :datetime        not null
#   updated_at         :datetime        not null
#
#  Indexes:
#   index_programms_on_with_programm_type  with_programm_type
#   index_programms_on_with_programm_id    with_programm_id
#--
# generated by 'annotated-rails' gem, please do not remove this line and content above, instead use `bundle exec annotate-rails -d` command
#++
