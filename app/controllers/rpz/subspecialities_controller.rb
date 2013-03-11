class Rpz::SubspecialitiesController < ApplicationController
  layout 'rpz'

  inherit_resources

  belongs_to :year, :finder => :find_by_number!, :optional => true

  actions :index, :show

  has_scope :actual, :default => true, :type => :boolean

  has_scope :education_form do |controller, scope, value|
    scope.with_education_form(value)
  end

  has_scope :degree do |controller, scope, value|
    scope.with_degree(value)
  end

  has_scope :ordered, :default => true, :type => :boolean, :only => :index

  expose(:current_year)           { @year || speciality.year }
  expose(:current_education_form) { params[:education_form] || subspeciality.model.education_form }
  expose(:current_degree)         { params[:degree] || speciality.model.degree }

  expose(:subspecialities)        { collection }
  expose(:subspeciality)          { resource.decorate }
  expose(:speciality)             { subspeciality.speciality }

  expose(:available_years) do
    Year.actual.ordered.includes(:actual_subspecialities => :speciality).where('subspecialities.education_form' => current_education_form).uniq
  end
end

