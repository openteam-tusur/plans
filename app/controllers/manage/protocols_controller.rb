class Manage::ProtocolsController < Manage::ApplicationController
  inherit_resources

  actions :all, :except => :index

  belongs_to :year, :finder => :find_by_number! do
    belongs_to :speciality, :finder => :find_by_code! do
      belongs_to :subspeciality do
        belongs_to :discipline do
          belongs_to :work_programm, :optional => true, :singleton => true
        end
      end
    end
  end

  layout false
end
