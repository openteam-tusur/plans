class Manage::SubspecialitiesController < Manage::ApplicationController
  actions :only => :show

  belongs_to :year, :finder => :find_by_number! do
    belongs_to :speciality, :finder => :find_by_code!
  end

  expose(:subspeciality) { resource.decorate }
  expose(:speciality) { subspeciality.speciality }
end
