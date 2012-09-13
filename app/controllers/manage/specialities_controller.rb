class Manage::SpecialitiesController < Manage::ApplicationController
  belongs_to :year, :finder => :find_by_number!

  defaults :finder => :find_by_code!

  actions :only => :index

  has_scope :consumed_by, :default => 1 do |controller, scope|
    scope.consumed_by(controller.current_user)
  end

  has_scope :degree do |controller, scope, value|
    scope.send value
  end
end
