Plans::Application.routes.draw do
  namespace :manage do
    #get '/messages/:folder' => 'messages#index',
      #:constraints => { :folder => /(drafts|reduxes|releases|checks_by_provided_subdepartment|checks_by_profiled_subdepartment|checks_by_graduated_subdepartment|checks_by_library|checks_by_methodological_office|checks_by_educational_office)/ },
      #:as => :scoped_messages

    get 'rups' => 'rups#index'

    resources :years, :only => [] do
      match 'statistics' => 'statistics#index'
      get '/specialities/:degree' => 'specialities#index',
        :constraints => { :degree => /(bachelor|magistracy|specialty)/ },
        :as => :scoped_specialities

      resources :specialities, :speciality_id => /.*/, :only => [] do
        resources :subspecialities, :only => :show do
          resource :programm
          resource :work_plan
          resources :discipline, :only => [] do
            resources :work_programms, :except => :index do
              get 'edit_purpose',                :on => :member
              get 'get_didactic_units',          :on => :member
              get 'get_event_actions',           :on => :member
              get 'get_purpose',                 :on => :member
              get 'get_related_disciplines',     :on => :member
              put 'return_to_author',            :on => :member
              put 'shift_up',                    :on => :member
              resource  :protocol,               :except => :index
              resources :examination_questions,  :except => :index
              resources :exercises,              :except => :index do
                resource :appendix,              :except => [:index, :show]
              end
              resources :missions,               :except => :index
              resources :people,                 :except => :index
              resources :publications,           :except => :index
              resources :rating_items,           :except => :index
              resources :requirements,           :except => [:create, :index, :new]
              resources :self_education_items,   :except => :index do
                resource :appendix,              :except => [:index, :show]
              end
            end
          end
        end
      end
    end

    resources :goses, :only => [:index, :show] do
      resources :didactic_units, :except => :index
    end

    resources :subdepartments, :only => [] do
      resources :disciplines, :only => :index
    end

    root :to => 'specialities#redirect_to_year_and_degree'
  end

  namespace :edu do
    get '/gos/:gos_generation' => 'goses#show', :constraints => { :gos_generation => /(2$|3$|3[.]5$)/}, :as => :gos
    get '/gos/:gos_generation/by_year' => 'goses#show_by_year', :constraints => { :gos_generation => /(2$|3$|3[.]5$)/}, :as => :gos_by_year
    resources :subspecialities, :only => :show do
      resources :disciplines, :only => :show
    end
    root :to => 'goses#index'
  end

  namespace :rpz do
    resources :years, :only => [] do
      get '/:degree/:education_form' => 'subspecialities#index',
        :constraints => {
          :degree         => /(bachelor|magistracy|specialty)/,
          :education_form => /(full-time|part-time|postal|postal-with-dist)/
        },
        :as => :subspecialities
    end
    resources :subspecialities, :only => :show do
      resources :semesters, only: :show
    end
    root :to => 'subspecialities#index', :year_id => '2007', :degree => 'specialty', :education_form => 'full-time'
  end

  root :to => 'application#index'

  mount API::Plans => '/api'
end
