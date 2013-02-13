class Plans::SubspecialitiesController < ApplicationController
  layout 'portal'

  expose(:subspeciality) { SubspecialityDecorator.decorate(Subspeciality.find(params[:id])) }

  def show
  end
end
