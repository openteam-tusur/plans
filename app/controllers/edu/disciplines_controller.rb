class Edu::DisciplinesController < ApplicationController
  layout 'edu'

  expose(:subspeciality) { SubspecialityDecorator.decorate(Subspeciality.find(params[:subspeciality_id])) }
  expose(:speciality) { subspeciality.speciality }
  expose(:discipline) { DisciplineDecorator.decorate(subspeciality.actual_disciplines.find(params[:id])) }

  def show
  end
end
