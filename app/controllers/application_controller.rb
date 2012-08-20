class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'blank', :only => :index

  def index
  end
end
