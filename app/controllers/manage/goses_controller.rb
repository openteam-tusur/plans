class Manage::GosesController < Manage::ApplicationController
  inherit_resources
  actions :all, :only => [:index, :show]
end
