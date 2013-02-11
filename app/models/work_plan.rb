class WorkPlan < ActiveRecord::Base
  attr_accessible :description, :file

  belongs_to :subspeciality
  validates_presence_of :description, :subspeciality

  has_attached_file :file, :storage => :elvfs, :elvfs_url => Settings['storage.url']
  validates :file, :attachment_presence => true
end
