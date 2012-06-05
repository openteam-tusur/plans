class SubspecialitiesController < ApplicationController
  belongs_to :speciality, :finder => :find_by_code!
end
