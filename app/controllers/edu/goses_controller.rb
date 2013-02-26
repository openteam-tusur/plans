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
                 .where('specialities.gos_generation' => params[:gos_generation])
                 .order('specialities.code, subspecialities.title, subdepartments.abbr, subspecialities.education_form, subspecialities.reduced desc')
                 .decorate
  end

  def show
  end

  def show_by_year
  end

  def index
  end
end
