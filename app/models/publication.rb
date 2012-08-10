# encoding: utf-8

class Publication < ActiveRecord::Base
  attr_accessible :publication_kind, :text, :url, :work_programm_id, :location, :count

  belongs_to :work_programm

  validates_presence_of :text, :location
  validates_presence_of :url, :if => ->(p) { p.location_portal? || p.location_lan? }
  validates_presence_of :count, :if => :location_library?
  validates_numericality_of :count, :greater_than => 0, :only_integer => true, :if => :location_library?

  has_enums

  def to_s
    text.tap do |s|
      s << ". URL: #{url}"  if url?
      s << ". #{count} экз."  if count?
    end
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

