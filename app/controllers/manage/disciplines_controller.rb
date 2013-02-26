class Manage::DisciplinesController < Manage::ApplicationController
  inherit_resources
  actions :index
  belongs_to :subdepartment

  has_scope :actual, :default => true, :type => :boolean

  has_scope :eager_load_associations, :default => true, :type => :boolean do |controller, scope, value|
    scope
      .includes(:subspeciality, :speciality, :work_programms)
      .order('specialities.code, subspecialities.title, subspecialities.education_form, subspecialities.reduced desc, disciplines.cycle, disciplines.title')
  end

  expose(:subspecialities_with_disciplines) { collection.decorate.group_by(&:subspeciality) }
  expose(:subdepartment) { parent }
end
