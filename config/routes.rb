Plans::Application.routes.draw do
  resources :years, :only => []  do
    match 'statistics' => 'statistics#index'

    resources :specialities, :speciality_id => /.*/, :only => :index do
      resources :subspecialities, :only => :show do
        resource :programm
        resources :disciplines, :only => [] do
          resources :work_programms do
            resources :dependent_disciplines
            resources :lectures, :except => :index
          end
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
