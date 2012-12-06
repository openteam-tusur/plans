class Manage::StatisticsController < ApplicationController
  before_filter :authenticate_user!
  layout 'manage'

  def index
    @year = Year.find_by_number(params[:year_id])
    @departments = @year.departments.actual
  end
end
