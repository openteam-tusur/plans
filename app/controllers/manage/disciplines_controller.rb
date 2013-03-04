class Manage::DisciplinesController < Manage::ApplicationController
  inherit_resources

  belongs_to :subdepartment

  actions :index
  custom_actions :collection => :index

  has_scope :actual, :default => true, :type => :boolean

  has_scope :consumed_by_current_user, :default => true, :type => :boolean do |controller, scope, value|
     scope.consumed_by(controller.current_user)
  end

  has_scope :eager_load_associations, :default => true, :type => :boolean do |controller, scope, value|
    scope
      .includes(:work_programms => {:discipline => {:subspeciality => {:speciality => :year}}}, :subspeciality => :speciality)
      .order('specialities.code, subspecialities.title, subspecialities.education_form, subspecialities.reduced desc, disciplines.title')
  end

  expose(:subspecialities_with_disciplines) { collection.group_by(&:subspeciality) }
  expose(:subdepartments) { Subdepartment.consumed_by(current_user).ordered }
  expose(:subdepartment) { parent }

  skip_load_resource :only => :redirect_to_available_subdepartment
  skip_authorize_resource :only => :redirect_to_available_subdepartment

  def redirect_to_available_subdepartment
    redirect_to [:manage, Subdepartment.consumed_by(current_user).ordered.first, :disciplines]
  end
end
