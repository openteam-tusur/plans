Plans::Application.routes.draw do
  resources :years, :only => []  do
    match 'statistics' => 'statistics#index'
    resources :specialities, :id => /.*/, :only => :index do
      resources :subspecialities, :only => :show do
        resource :programm
        resources :disciplines, :only => [] do
          resources :work_programms
        end
      end
    end
  end

  resources :goses do
    resources :didactic_units, :except => :index
  end

  root :to => 'specialities#index'
  mount ElVfsClient::Engine => '/'
end
