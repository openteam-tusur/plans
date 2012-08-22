class Manage::SpecialitiesController < Manage::ApplicationController
  belongs_to :year, :finder => :find_by_number!
  defaults :finder => :find_by_code!
  has_scope :consumed_by, :default => 1 do |controller, scope|
    scope.consumed_by(controller.current_user)
  end
end
