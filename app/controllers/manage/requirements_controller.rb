class Manage::RequirementsController < Manage::ApplicationController
  inherit_resources

  actions :all, :except => [:index, :new, :create]

  belongs_to :year, :finder => :find_by_number! do
    belongs_to :speciality, :finder => :find_by_code! do
      belongs_to :subspeciality do
        belongs_to :discipline do
          belongs_to :work_programm, :optional => true
        end
      end
    end
  end

  layout false
end
