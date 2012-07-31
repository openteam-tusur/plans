Plans::Application.routes.draw do
  resources :years, :only => []  do
    match 'statistics' => 'statistics#index'

    resources :specialities, :speciality_id => /.*/, :only => :index do
      resources :subspecialities, :only => :show do
        resource :programm
        resources :disciplines, :only => [] do
          resources :work_programms do
            resources :dependent_disciplines
            resources :exercises,    :except => :index
            resources :missions,     :except => :index
            resources :publications, :except => :index
            resources :requirements, :except => [:index, :new, :create]
            resources :rating_items, :except => :index
            resource :self_education, :except => :show
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
