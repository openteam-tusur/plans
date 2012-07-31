class RatingItem < ActiveRecord::Base
  attr_accessible :max_1kt_2kt, :max_2kt_end, :max_begin_1kt, :title, :semester_id

  belongs_to :work_programm
  belongs_to :semester

  validates_presence_of :max_1kt_2kt, :max_2kt_end, :max_begin_1kt, :title

  def total_score
    [max_begin_1kt, max_1kt_2kt, max_2kt_end].sum
  end
end
