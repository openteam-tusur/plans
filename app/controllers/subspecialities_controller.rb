class SubspecialitiesController < ApplicationController
  belongs_to :year, :finder => :find_by_number! do
    belongs_to :speciality, :finder => :find_by_code!
  end
end
