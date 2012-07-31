# encoding: utf-8

class Discipline < ActiveRecord::Base
  attr_accessible :title

  belongs_to :subspeciality
  belongs_to :subdepartment

  has_one :programm, :as => :with_programm
  has_many :checks, :dependent => :destroy
  has_many :loadings, :dependent => :destroy
  has_many :work_programms, :dependent => :destroy
  has_many :semesters, :through => :loadings, :uniq => true

  scope :actual, where(:deleted_at => nil)

  validates_presence_of :title, :subspeciality, :subdepartment

  alias_attribute :deleted?, :deleted_at?

  after_save :move_descendants_to_trash, :if => [:deleted_at_changed?, :deleted_at?]

  def move_descendants_to_trash
    checks.update_all(:deleted_at => Time.now)
    loadings.update_all(:deleted_at => Time.now)
  end

  def to_s
    title
  end

  def has_exam_at_semester?(semester)
    checks.where(:semester_id => semester).pluck(:check_kind).include?('exam')
  end
end

# == Schema Information
#
# Table name: disciplines
#
#  id               :integer          not null, primary key
#  title            :string(255)
#  cycle            :string(255)
#  subspeciality_id :integer
#  subdepartment_id :integer
#  deleted_at       :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  summ_loading     :integer
#  summ_srs         :integer
#  code             :string(255)
#  component        :string(255)
#

