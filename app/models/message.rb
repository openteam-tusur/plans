class Message < ActiveRecord::Base
  belongs_to :work_programm
  attr_accessible :readed, :text
  default_value_for :readed, false

  scope :unreaded,                        where(:readed => false)

  scope :drafts,                          ->(user){ unreaded.where(:work_programm_id => WorkProgramm.drafts(user)) }
  scope :reduxes,                         ->(user){ unreaded.where(:work_programm_id => WorkProgramm.reduxes(user)) }
  scope :releases,                        ->(user){ unreaded.where(:work_programm_id => WorkProgramm.releases(user)) }
  scope :checks_by_provided_subdivision,  ->(user){ unreaded.where(:work_programm_id => WorkProgramm.checks_by_provided_subdivision(user)) }
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
end
