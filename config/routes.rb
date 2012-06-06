Plans::Application.routes.draw do
  resources :years, :only => []  do
    resources :specialities, :id => /.*/, :only => :index do
      resources :subspecialities, :only => :show do
        resource :programm
      end
    end
  end

  root :to => 'specialities#index'
  mount ElVfsClient::Engine => '/'
end
