class Portal::SubspecialitiesController < ApplicationController
  expose(:subspeciality) { SubspecialityDecorator.decorate(Subspeciality.find(params[:id])) }

  def show
  end
end
