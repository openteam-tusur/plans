class Speciality < ActiveRecord::Base
  attr_accessible :code, :title, :degree, :gos_generation

  belongs_to :year

  has_many :subspecialities, :order => :title
  has_many :actual_subspecialities, :class_name => 'Subspeciality', :conditions => { :deleted_at => nil }
  has_many :disciplines, :through => :subspecialities
  has_many :actual_disciplines, :through => :actual_subspecialities
  has_many :programms, :through => :actual_subspecialities
  has_many :work_plans, :through => :actual_subspecialities
  has_many :subdepartments, :through => :actual_subspecialities
  has_many :work_programms

  validates_presence_of :code, :title, :degree, :year

  after_save :move_subspeciality_to_trash, :if => [:deleted_at_changed?, :deleted_at?]

  scope :ordered, -> { order(:code) }
  scope :actual, -> { where(:deleted_at => nil) }
  scope :gos3,   -> { where(:gos_generation => '3') }
  scope :gos3_new,   -> { where(:gos_generation => '3.5') }
  scope :gos3_all,   -> { where(:gos_generation => ['3', '3.5'])}

  # TODO: only permitted for non managers
  scope :consumed_by, ->(user) do
    scoped
  end

  delegate :consumed_by, :to => :subspecialities, :prefix => true

  extend Enumerize
  enumerize :degree, :in => %w[bachelor magistracy specialty], :scope => true, :predicates => true

  def to_param
    code
  end

  def gos
    Gos.find_by_speciality_code(code) || Gos.new(:title => '-'*20)
  end

  def gos?
    Gos.where(:speciality_code => code).any?
  end

  def gos2?
    gos_generation == '2'
  end

  def gos3?
    gos_generation == '3'
  end

  def gos3_new?
    gos_generation == '3.5'
  end

  def to_s
    "#{code} &mdash; #{title}".html_safe
  end

  private

    def move_subspeciality_to_trash
      subspecialities.update_all(:deleted_at => Time.now)
    end
end

# == Schema Information
#
# Table name: specialities
#
#  id             :integer          not null, primary key
#  code           :string(255)
#  title          :string(255)
#  degree         :string(255)
#  year_id        :integer
#  deleted_at     :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  gos_generation :string(255)
#

