class StatisticsController < ApplicationController
  def index
    @year = Year.find_by_number(params[:year_id])
    @departments = @year.departments
  end
end
