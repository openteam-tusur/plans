# == Schema Information
#
# Table name: work_plans
#
#  id                :integer          not null, primary key
#  subspeciality_id  :integer
#  file_file_name    :text
#  file_content_type :text
#  file_file_size    :integer
#  file_updated_at   :datetime
#  file_url          :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class WorkPlan < ActiveRecord::Base
  attr_accessible :description, :file

  belongs_to :subspeciality
  validates_presence_of :subspeciality

  has_attached_file :file, :storage => :elvfs, :elvfs_url => Settings['storage.url']
  validates :file, :attachment_presence => true
end
