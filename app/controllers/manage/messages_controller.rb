class Manage::MessagesController < Manage::ApplicationController
  inherit_resources
  actions :only => :index

  has_scope :folder do |controller, scope, value|
    scope.send value, controller.current_user
  end
end
