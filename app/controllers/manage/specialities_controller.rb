class Manage::SpecialitiesController < Manage::ApplicationController
  belongs_to :year, :finder => :find_by_number!

  defaults :finder => :find_by_code!

  actions :only => :index

  custom_actions :collection => :index

  has_scope :consumed_by, :default => true, :type => :boolean do |controller, scope|
    scope.consumed_by(controller.current_user)
  end

  has_scope :actual, :default => true, :type => :boolean

  has_scope :degree do |controller, scope, value|
    scope.with_degree value
  end

  has_scope :eager_load_associations, :default => true, :type => :boolean, :only => :index do |controller, scope|
    scope.includes(:actual_disciplines).includes(:programms).includes(:work_plans).includes(:subdepartments).includes(:actual_subspecialities)
  end

  skip_load_resource :only => :redirect_to_year_and_degree
  skip_authorize_resource :only => :redirect_to_year_and_degree

  def redirect_to_year_and_degree
    redirect_to manage_year_scoped_specialities_path((year = Year.find_by_number(2011)), :degree => year.specialities.pluck(:degree).uniq.sort.first)
  end
end
