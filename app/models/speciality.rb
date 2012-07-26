class Speciality < ActiveRecord::Base
  attr_accessible :code, :title, :degree

  belongs_to :year

  has_many :subspecialities
  has_many :work_programms

  validates_presence_of :code, :title, :degree, :year

  after_save :move_subspeciality_to_trash, :if => [:deleted_at_changed?, :deleted_at?]

  default_scope order(:code)

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

# == Schema Information
#
# Table name: specialities
#
#  id         :integer          not null, primary key
#  code       :string(255)
#  title      :string(255)
#  degree     :string(255)
#  year_id    :integer
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

