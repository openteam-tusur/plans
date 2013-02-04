# encoding: utf-8

class Programm < ActiveRecord::Base
  attr_accessible :description, :file
  belongs_to :with_programm, :polymorphic => true
  validates_presence_of :description, :with_programm

  has_attached_file :file, :storage => :elvfs, :elvfs_url => Settings['storage.url']
  validates :file, :attachment_presence => true
end

# == Schema Information
#
# Table name: programms
#
#  id                 :integer          not null, primary key
#  with_programm_id   :integer
#  with_programm_type :string(255)
#  description        :text
#  vfs_path           :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

