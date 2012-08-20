class Manage::DidacticUnitsController < Manage::ApplicationController
  inherit_resources

  actions :all, :except => :index

  belongs_to :gos
end
