class Manage::SpecialitiesController < Manage::ApplicationController
  belongs_to :year, :finder => :find_by_number!
  defaults :finder => :find_by_code!
end
