class Speciality < ActiveRecord::Base
  attr_accessible :code, :title, :degree

  belongs_to :year

  has_many :subspecialities
  has_many :actual_subspecialities, :class_name => 'Subspeciality', :conditions => { :deleted_at => nil }
  has_many :disciplines, :through => :subspecialities
  has_many :actual_disciplines, :through => :actual_subspecialities
  has_many :programms, :through => :actual_subspecialities
  has_many :work_plans, :through => :actual_subspecialities
  has_many :subdepartments, :through => :actual_subspecialities
  has_many :work_programms

  validates_presence_of :code, :title, :degree, :year

  after_save :move_subspeciality_to_trash, :if => [:deleted_at_changed?, :deleted_at?]

  default_scope order(:code)

  scope :bachelor,    where(:degree => 'bachelor')
  scope :magistracy,  where(:degree => 'magistracy')
  scope :specialty,   where(:degree => 'specialty')

  scope :actual, -> { where(:deleted_at => nil) }

  scope :consumed_by, ->(user) do
    if user.manager?
      subdepartment_ids = user.context_tree.flat_map(&:subdepartment_ids)
      select('DISTINCT(specialities.id), specialities.*').
        joins(:subspecialities).
        joins('LEFT OUTER JOIN disciplines ON disciplines.subspeciality_id = subspecialities.id').
        where('disciplines.subdepartment_id IN (?) OR subspecialities.subdepartment_id IN (?)', subdepartment_ids, subdepartment_ids)
    elsif user.lecturer?
      where(:id => user.context_tree.map(&:subspeciality).map(&:speciality_id))
    else
      where(:id => nil)
    end
  end

  delegate :consumed_by, :to => :subspecialities, :prefix => true

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

