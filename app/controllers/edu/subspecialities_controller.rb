class Edu::SubspecialitiesController < ApplicationController
  layout 'edu'

  expose(:subspeciality) { SubspecialityDecorator.decorate(Subspeciality.find(params[:id])) }
  expose(:speciality) { subspeciality.speciality }

  def show
  end
end
