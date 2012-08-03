class SelfEducationItem < ActiveRecord::Base
  belongs_to :work_programm
  belongs_to :semester

  has_one :appendix, :as => :appendixable

  attr_accessible :control, :hours, :kind, :semester_id

  scope :kind, ->(kind) { where :kind => kind }
  scope :semester_id, ->(semester) { where :semester_id => semester }

  before_create :set_weight

  validates_presence_of :semester, :work_programm

  has_enum :control, :multiple => true

  FIFTH_ITEM_KINDS = %w[home_work referat test colloquium calculation]

  ALL_KINDS  = %w[lecture lab practice csr home_work referat test colloquium calculation srs exam]
  AVAILABLE_CONTROLS = {
        lecture:      [:quiz, :test, :home_work],
        lab:          [:access, :defence],
        practice:     [:quiz, :test, :check],
        csr:          [:report],
        home_work:    [:defence, :mark],
        referat:      [:defence, :mark],
        test:         [:check, :mark],
        colloquium:   [:defence, :mark],
        calculation:  [:defence, :mark],
        srs:          [:check_summary, :quiz, :test, :home_work],
        exam:         [:pass]
  }

  def self.available_human_control_values(kind)
    human_enum_values(:control).keep_if{|key, value| AVAILABLE_CONTROLS[kind.to_sym].include?(key.to_sym) }.invert
  end

  def set_weight
    self.weight = semester.number * 100 + ALL_KINDS.index(kind)
  end
end

# == Schema Information
#
# Table name: self_education_items
#
#  id               :integer          not null, primary key
#  work_programm_id :integer
#  semester_id      :integer
#  kind             :string(255)
#  hours            :integer
#  control          :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  weight           :integer
#

