# encoding: utf-8
# == Schema Information
#
# Table name: publications
#
#  id               :integer          not null, primary key
#  work_programm_id :integer
#  kind             :string(255)
#  text             :text
#  url              :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  location         :string(255)
#  count            :integer
#


class Publication < ActiveRecord::Base
  attr_accessible :kind, :text, :url, :work_programm_id, :location, :count

  belongs_to :work_programm

  validates_presence_of :text, :location
  validates_presence_of :url, :if => ->(p) { p.location_portal? || p.location_lan? }
  validates_presence_of :count, :if => :location_library?
  validates_numericality_of :count, :greater_than => 0, :only_integer => true, :if => :location_library?
  validates_format_of :url, :with => /\A#{URI::regexp(%w[http htps])}\Z/, :if => :url?

  extend Enumerize
  enumerize :kind,      :in => %w[basic additional ump_practice ump_lab ump_srs ump_course_work ump_csr]
  enumerize :kind_add,  :in => %w[basic additional ump_practice ump_lab ump_srs ump_course_work ump_csr]
  enumerize :location,  :in => %w[lan library portal other], :predicates => { :prefix => true }

  def to_s
    text.tap do |s|
      s << ". URL: #{url}"  if url?
      s << ". #{count} экз."  if count?
    end
  end
end
