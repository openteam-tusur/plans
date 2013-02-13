class Plans::GosesController < ApplicationController
  layout 'portal'

  expose(:subspecialities) do
    Subspeciality.includes(:speciality)
                 .includes(:year)
                 .includes(:graduated_subdepartment)
                 .includes(:work_plan)
                 .where('specialities.gos_generation' => params[:gos_generation])
                 .actual
                 .order('specialities.code, subspecialities.title, years.number, subdepartments.abbr')
                 .decorate
  end

  def show
  end

  def index
  end
end
