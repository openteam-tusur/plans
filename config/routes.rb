Plans::Application.routes.draw do
  namespace :manage do
    resources :years, :only => [] do
      match 'statistics' => 'statistics#index'

      resources :specialities, :speciality_id => /.*/, :only => :index do
        resources :subspecialities, :only => :show do
          resource :programm
          resources :disciplines, :only => [] do
            resources :work_programms do
              resource :self_education,           :except => :show

              resources :appendixes,              :except => :show
              resources :dependent_disciplines
              resources :examination_questions,   :except => :index
              resources :missions,                :except => :index
              resources :publications,            :except => :index
              resources :rating_items,            :except => :index
              resources :requirements,            :except => [:index, :new, :create]
              resources :self_education_items,    :except => [:index] do
                resource :appendix,               :except => [:index, :show]
              end

              resources :exercises,               :except => :index do
                resource :appendix,               :except => [:index, :show]
              end
            end
          end
        end
      end
    end

    resources :goses do
      resources :didactic_units, :except => :index
    end

    root :to => 'specialities#index', :defaults => { :year_id => (Date.today - 6.month).year }
  end

  mount ElVfsClient::Engine => '/'
end
