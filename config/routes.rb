Plans::Application.routes.draw do
  namespace :manage do
    get '/messages/:folder' => 'messages#index',
      :constraints => { :folder => /(drafts|reduxes|releases|checks_by_provided_subdivision|checks_by_graduated_subdivision|checks_by_library|checks_by_methodological_office|checks_by_educational_office)/ },
      :as => :scoped_messages
    resources :messages, :only => :show
    resources :years, :only => [] do
      match 'statistics' => 'statistics#index'

      resources :specialities, :speciality_id => /.*/, :only => :index do
        resources :subspecialities, :only => :show do
          resource :programm
          resources :disciplines, :only => [] do
            resources :work_programms do
              get 'get_didactic_units', :on => :member
              get 'get_event_actions', :on => :member
              put 'shift_up', :on => :member
              put 'return_to_author', :on => :member
              resource  :protocol,                :except => :index
              resource  :self_education,          :except => :show
              resources :appendixes,              :except => :show
              resources :authors,                 :except => :index
              resources :dependent_disciplines
              resources :examination_questions,   :except => :index
              resources :exercises,               :except => :index do
                resource :appendix,               :except => [:index, :show]
              end
              resources :missions,                :except => :index
              resources :publications,            :except => :index
              resources :rating_items,            :except => :index
              resources :requirements,            :except => [:index, :new, :create]
              resources :self_education_items,    :except => [:index] do
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

    root :to => 'messages#index', :folder => 'drafts'
  end

  root :to => 'application#index'
  mount ElVfsClient::Engine => '/'
end
