class Message < ActiveRecord::Base
  belongs_to :work_programm
  attr_accessible :readed, :text
  default_value_for :readed, false

  before_create :set_work_programm_state

  scope :unreaded,                        where(:readed => false)

  scope :drafts,                          ->(user){ unreaded.where(:work_programm_id => WorkProgramm.drafts(user)) }
  scope :reduxes,                         ->(user){ unreaded.where(:work_programm_id => WorkProgramm.reduxes(user)) }
  scope :releases,                        ->(user){ unreaded.where(:work_programm_id => WorkProgramm.releases(user)) }
  scope :checks_by_provided_subdivision,  ->(user){ unreaded.where(:work_programm_id => WorkProgramm.checks_by_provided_subdivision(user)) }
  scope :checks_by_profiled_subdivision,  ->(user){ unreaded.where(:work_programm_id => WorkProgramm.checks_by_profiled_subdivision(user)) }
  scope :checks_by_graduated_subdivision, ->(user){ unreaded.where(:work_programm_id => WorkProgramm.checks_by_graduated_subdivision(user)) }
  scope :checks_by_library,               ->(user){ unreaded.where(:work_programm_id => WorkProgramm.checks_by_library(user)) }
  scope :checks_by_methodological_office, ->(user){ unreaded.where(:work_programm_id => WorkProgramm.checks_by_methodological_office(user)) }
  scope :checks_by_educational_office,    ->(user){ unreaded.where(:work_programm_id => WorkProgramm.checks_by_educational_office(user)) }

  def readed?
    readed
  end

  def read!
    self.readed = true
    self.save!
  end

  private
    def set_work_programm_state
      self.work_programm_state = I18n.t("message.#{work_programm.state}")
    end
end

# == Schema Information
#
# Table name: messages
#
#  id                  :integer          not null, primary key
#  text                :text
#  readed              :boolean
#  work_programm_id    :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  work_programm_state :string(255)
#

