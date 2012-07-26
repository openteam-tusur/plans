class Speciality < ActiveRecord::Base
  attr_accessible :code, :title, :degree

  belongs_to :year

  has_many :subspecialities
  has_many :work_programms

  validates_presence_of :code, :title, :degree, :year

  after_save :move_subspeciality_to_trash, :if => [:deleted_at_changed?, :deleted_at?]

  def to_param
    code
  end

  def gos
    Gos.find_by_speciality_code(code) || Gos.new(:title => '-'*20)
  end

  private

    def move_subspeciality_to_trash
      subspecialities.update_all(:deleted_at => Time.now)
    end
end
