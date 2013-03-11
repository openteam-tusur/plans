class Rpz::SubspecialitiesController < ApplicationController
  layout 'rpz'

  inherit_resources

  belongs_to :year, :finder => :find_by_number!, :optional => true

  actions :index, :show

  has_scope :actual, :default => true, :type => :boolean

  has_scope :education_form do |controller, scope, value|
    scope.with_education_form(value)
  end

  has_scope :load_associations, :default => true, :type => :boolean, :only => :index do |controller, scope|
    #scope.includes(:speciality, :subdepartment, :year)
    scope
  end

  has_scope :ordered, :default => true, :type => :boolean, :only => :index

  expose(:current_education_form) { params[:education_form] }
  expose(:current_year) { @year || @subspeciality.year }

  expose(:subspecialities) { collection }

  expose(:available_years) { Year.actual.ordered.joins(:subspecialities).where('subspecialities.education_form' => current_education_form).uniq }
  expose(:available_degrees) { current_year.subspecialities.with_education_form(current_education_form).pluck('distinct degree') }
end

