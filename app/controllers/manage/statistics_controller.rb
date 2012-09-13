class Manage::StatisticsController < Manage::ApplicationController
  esp_load_and_authorize_resource

  def index
    @year = Year.find_by_number(params[:year_id])
    @departments = @year.departments.actual
  end
end
