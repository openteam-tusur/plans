class SelfEducationItem < ActiveRecord::Base
  belongs_to :work_programm
  belongs_to :semester

  attr_accessible :control, :hours, :kind, :semester_id

  scope :kind, ->(kind) { where :kind => kind }
  scope :semester_id, ->(semester) { where :semester_id => semester }

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
end
