class Manage::SpecialitiesController < Manage::ApplicationController
  belongs_to :year, :finder => :find_by_number!

  defaults :finder => :find_by_code!

  actions :only => :index

  has_scope :consumed_by, :default => true, :type => :boolean do |controller, scope|
    scope.consumed_by(controller.current_user)
  end

  has_scope :actual, :default => true, :type => :boolean

  has_scope :degree do |controller, scope, value|
    scope.send value
  end

  has_scope :eager_load_associations, :default => 1, :only => :index do |controller, scope|
    scope.includes(:actual_disciplines).includes(:programms).includes(:work_plans).includes(:subdepartments).includes(:actual_subspecialities)
  end
end
