class SpecialitiesController < ApplicationController
  belongs_to :year, :finder => :find_by_number!
  defaults :finder => :find_by_code!

  before_filter :set_year

  private

  def set_year
    params[:year_id] = (Date.today - 6.month).year.to_s unless params[:year_id]
  end
end
