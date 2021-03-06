class SelfEducationItem < ActiveRecord::Base
  belongs_to :work_programm
  belongs_to :semester

  has_one :appendix, :as => :appendixable

  attr_accessible :control, :hours, :kind, :semester_id

  scope :kind, ->(kind) { where :kind => kind }
  scope :semester_id, ->(semester) { where :semester_id => semester }

  before_create :set_weight

  validates_presence_of :semester, :work_programm, :hours, :kind, :control
  validates_numericality_of :hours, :greater_than => 0, :only_integer => true
  validates_uniqueness_of :kind, :scope => [:semester_id, :work_programm_id]

  default_scope order('self_education_items.weight, self_education_items.id')

  extend Enumerize

  serialize :control, Array
  enumerize :control, :in => %w[quiz test home_work access defence check report mark check_summary exam], :multiple => true

  FIFTH_ITEM_KINDS = %w[home_work individual_work referat test colloquium calculation]
  ALL_KINDS  = %w[lecture lab practice csr home_work individual_work referat test colloquium calculation srs exam]

  AVAILABLE_CONTROLS = {
        lecture:          [:quiz, :test, :home_work],
        lab:              [:access, :defence],
        practice:         [:quiz, :test, :check],
        csr:              [:report],
        home_work:        [:defence, :mark],
        individual_work:  [:defence, :mark],
        referat:          [:defence, :mark],
        test:             [:check, :mark],
        colloquium:       [:defence, :mark],
        calculation:      [:defence, :mark],
        srs:              [:check_summary, :quiz, :test, :home_work],
        exam:             [:pass]
  }
  CONTROL_TYPES = %[quiz test home_work access defence check report mark check_summary pass]

  def kind_collection_for_select
    available_kinds.map { |kind|  [SelfEducationItem.human_attribute_name(kind), kind] }
  end

  def self.control_collection_for_select
    control.options
  end

  def set_weight
    self.weight = semester.number
  end

  def title
    SelfEducationItem.human_attribute_name(kind)
  end

  def item_valid?
    (FIFTH_ITEM_KINDS.include?(kind) && appendix) || !FIFTH_ITEM_KINDS.include?(kind)
  end

  def human_control
    control.map(&:text).join(', ')
  end

  private

    def available_kinds
      kinds = ALL_KINDS
      kinds -= SelfEducationItem.where(:semester_id => semester_id).where(:work_programm_id => work_programm_id).pluck(:kind)
      kinds -= (Loading.kind.values - work_programm.discipline.loadings.where(:semester_id => semester_id).pluck(:kind))
      kinds << kind if persisted?
      kinds
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

