class Exercise < ActiveRecord::Base
  attr_accessible :description, :title, :volume, :semester_id, :kind, :work_programm_id

  belongs_to :semester
  belongs_to :work_programm

  validates_presence_of :description, :title, :volume, :semester, :kind

  default_scope order('id ASC')

  has_enum :kind
end

# == Schema Information
#
# Table name: exercises
#
#  id               :integer          not null, primary key
#  title            :string(255)
#  description      :text
#  volume           :integer
#  work_programm_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  semester_id      :integer
#  kind             :string(255)
#

