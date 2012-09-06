# encoding: utf-8
class DidacticUnit < ActiveRecord::Base
  attr_accessible :content, :discipline

  belongs_to :gos

  validates_presence_of :content, :discipline

  alias_attribute :to_s, :discipline

  def lecture_themes(totals)
    lecture_counts = totals.map {|total| (total * all_lecture_themes.count / totals.sum.to_f).ceil }
    [].tap do |lecture_themes|
      lecture_counts[0..-2].each do |count|
        lecture_themes << all_lecture_themes.shift([count, all_lecture_themes.count - 1].min)
      end
      lecture_themes << all_lecture_themes
    end
  end

  def all_lecture_themes
    @all_lecture_themes ||= content.split(/[\n;]+\s*|\.\s*$|\.\s*(?=[А-ЯЁA-Z])/).map{|lecture| lecture[0] = lecture[0].mb_chars.upcase; lecture }
  end
end

# == Schema Information
#
# Table name: didactic_units
#
#  id         :integer          not null, primary key
#  gos_id     :integer
#  discipline :string(255)
#  content    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

