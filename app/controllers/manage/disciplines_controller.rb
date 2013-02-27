class Manage::DisciplinesController < Manage::ApplicationController
  inherit_resources

  actions :index

  has_scope :actual, :default => true, :type => :boolean
  has_scope :subdepartment_abbr
  has_scope :eager_load_associations, :default => true, :type => :boolean do |controller, scope, value|
    scope
      .includes(:work_programms, :subspeciality => :speciality)
      .order('specialities.code, subspecialities.title, subspecialities.education_form, subspecialities.reduced desc, disciplines.title')
  end

  expose(:subspecialities_with_disciplines) { collection.group_by(&:subspeciality) }
  expose(:subdepartment_abbrs) { Subdepartment.joins(:actual_disciplines).actual.pluck(:abbr).uniq.sort }
end
