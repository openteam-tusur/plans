
class WorkProgrammsController < ApplicationController
  inherit_resources

  belongs_to :year, :finder => :find_by_number! do
    belongs_to :speciality, :finder => :find_by_code! do
      belongs_to :subspeciality do
        belongs_to :discipline
      end
    end

  end
end
