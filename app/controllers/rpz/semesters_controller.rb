class Rpz::SemestersController < ApplicationController
  layout 'print'
  inherit_resources
  belongs_to :subspeciality

  actions :show
  expose(:disciplines)            { parent.disciplines.ordered.includes(:loadings, :checks, :subdepartment) }
end
