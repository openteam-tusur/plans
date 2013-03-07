class Rpz::SubspecialitiesController < ApplicationController
  protect_from_forgery
  layout 'public'

  inherit_resources

  actions :index, :show

  has_scope :actual, :default => true, :type => :boolean

  has_scope :education_form do |controller, scope, value|
    scope.with_education_form(value)
  end

  has_scope :load_associations, :default => true, :type => :boolean, :only => :index do |controller, scope|
    scope.includes(:speciality, :subdepartment, :year)
  end

  has_scope :ordered, :default => true, :type => :boolean, :only => :index

  expose(:grouped_subspecialities) {
    collection.group_by(&:year)
  }
end

