class Edu::GosesController < ApplicationController
  layout 'edu'

  expose(:subspecialities) do
    Subspeciality.actual
                 .includes(:actual_disciplines)
                 .includes(:graduated_subdepartment)
                 .includes(:speciality)
                 .includes(:work_plan)
                 .includes(:year)
                 .joins(:graduated_subdepartment)
                 .joins(:speciality)
                 .joins(:year)
                 .where('specialities.gos_generation' => params[:gos_generation])
                 .order('specialities.code, subspecialities.title, years.number, subdepartments.abbr')
                 .decorate
  end

  def show
  end

  def show_by_year
  end

  def index
  end
end
