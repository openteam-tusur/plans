class RatingItem < ActiveRecord::Base
  attr_accessible :max_1kt_2kt, :max_2kt_end, :max_begin_1kt, :title, :semester_id, :rating_item_kind

  belongs_to :work_programm
  belongs_to :semester

  validates_presence_of :max_1kt_2kt, :max_2kt_end, :max_begin_1kt, :title

  extend Enumerize
  enumerize :rating_item_kind, :in => %w[default csr], :scope => true

  def total_score
    [max_begin_1kt, max_1kt_2kt, max_2kt_end].sum
  end
end

# == Schema Information
#
# Table name: rating_items
#
#  id               :integer          not null, primary key
#  work_programm_id :integer
#  semester_id      :integer
#  title            :string(255)
#  max_begin_1kt    :integer
#  max_1kt_2kt      :integer
#  max_2kt_end      :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  rating_item_kind :string(255)
#

