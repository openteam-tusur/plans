# encoding: utf-8
# == Schema Information
#
# Table name: programms
#
#  id                :integer          not null, primary key
#  subspeciality_id  :integer
#  description       :text
#  vfs_path          :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  file_file_name    :string(255)
#  file_content_type :string(255)
#  file_file_size    :integer
#  file_updated_at   :datetime
#  file_url          :text
#


class Programm < ActiveRecord::Base
  attr_accessible :description, :file

  belongs_to :subspeciality
  validates_presence_of :description, :subspeciality

  has_attached_file :file, :storage => :elvfs, :elvfs_url => Settings['storage.url']
  validates :file, :attachment_presence => true
end
