class DependentDiscipline < ActiveRecord::Base
  attr_accessible :dependency_id, :dependency_type, :title
  belongs_to :work_programm
  validates_presence_of :title, :dependency_type
  validates_associated :work_programm
  validates_uniqueness_of :title, :scope => :work_programm_id
  validates_inclusion_of :title, :in => ->(item){ item.work_programm.disciplines.map(&:title) }

  delegate :disciplines, :to => :work_programm, :prefix => true
  scope :subsequent_disciplines,  where(:dependency_type => 'subsequent')
  scope :current_disciplines,     where(:dependency_type => 'current')
  scope :previous_disciplines,    where(:dependency_type => 'previous')
end

# == Schema Information
#
# Table name: dependent_disciplines
#
#  id               :integer          not null, primary key
#  title            :text
#  dependency_type  :string(255)
#  work_programm_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

