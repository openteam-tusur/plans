# encoding: utf-8

class Appendix < ActiveRecord::Base
  attr_accessible :title, :appendix_items_attributes

  belongs_to :appendixable, :polymorphic => true

  delegate :work_programm, :work_programm=, :to => :appendixable

  has_many :appendix_items, :dependent => :destroy

  accepts_nested_attributes_for :appendix_items, :allow_destroy => true

  validates_presence_of :title

  def to_s
    "#{self.class.model_name.human.mb_chars.titleize}. #{title}"
  end

  def number
    appendixable.work_programm.appendixes.index(self) + 1
  end

  def to_s
    "#{self.class.model_name.human.mb_chars.titleize} #{number}. «#{title}»"
  end
end

# == Schema Information
#
# Table name: appendixes
#
#  id                :integer          not null, primary key
#  appendixable_id   :integer
#  appendixable_type :string(255)
#  title             :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

