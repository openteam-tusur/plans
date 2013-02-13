class Plans::SubspecialitiesController < ApplicationController
  layout 'portal'

  expose(:subspeciality) { SubspecialityDecorator.decorate(Subspeciality.find(params[:id])) }
  expose(:speciality) { subspeciality.speciality }

  def show
  end
end
