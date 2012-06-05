Plans::Application.routes.draw do
  resources :years, :only => []  do
    resources :specialities, :id => /.*/, :only => :index do
      resources :subspecialities, :only => :show
    end
  end

  root :to => 'specialities#index'
end
