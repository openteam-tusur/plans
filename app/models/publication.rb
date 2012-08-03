class Publication < ActiveRecord::Base
  attr_accessible :publication_kind, :text, :url, :work_programm_id

  belongs_to :work_programm

  validates_presence_of :text

  has_enum :publication_kind

  def to_s
    "#{text}".tap { |s| s << ". URL: #{url}"  if url? }
  end
end

# == Schema Information
#
# Table name: publications
#
#  id               :integer          not null, primary key
#  work_programm_id :integer
#  publication_kind :string(255)
#  text             :text
#  url              :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

