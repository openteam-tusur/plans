# encoding: utf-8

class API::Plans < Grape::API
  version 'v1', :using => :path

  rescue_from ActiveRecord::RecordNotFound

  format :json

  get :ping do
    :ok
  end

  helpers do
    def subspeciality
      @subspeciality ||= Subspeciality.actual.find(params[:subspeciality_id])
    end

    def subspeciality_by_group
      Subspeciality.unscoped.actual.ordered_by_year_desc.each do |subspeciality|
        next unless subspeciality.group_index
        return subspeciality if params[:group_number].match(Regexp.new(subspeciality.group_index))
      end
      nil
    end

    def semester
      subspeciality.semesters.actual.find_by_number!(params[:semester])
    end

    def subdepartment
      Subdepartment.find_by_abbr(params[:subdepartment])
    end

    def year
      Year.find_by_number!(params[:year])
    end
  end

  namespace :disciplines do
    params do
      requires :subspeciality_id, :type => Integer, :desc => "id of subspeciality"
    end

    namespace ":subspeciality_id" do
      desc 'Retrieve subspeciality disciplines in semester'
      params do
        requires :semester, :type => Integer, :desc => "number of semester"
      end
      get ":semester" do
        present semester.disciplines.actual, :with => API::Entities::Discipline, :semester => semester
      end
    end
  end

  namespace :disciplines_provided_by do
    params do
      requires :subdepartment, :type => String, :desc => 'Name of subdepartment'
    end
    get ':subdepartment' do
      present subdepartment, :with => API::Entities::ProvidedDiscipline
    end
  end

  desc 'Redirect to work_plan'
  namespace :work_plans do
    params do
      requires :subspeciality_id, :type => Integer, :desc => "id of subspeciality"
    end
    get ":subspeciality_id" do
      redirect subspeciality.work_plan.try :file_url
    end
  end

  namespace :programms do
    params do
      requires :subspeciality_id, :type => Integer, :desc => 'id of subspeciality'
    end
    get ":subspeciality_id" do
      redirect subspeciality.programm.try :file_url
    end
  end

  namespace :subspecialities do
    namespace :by_group do
      get ":group_number" do
        present subspeciality_by_group, with: API::Entities::Subspeciality
      end
    end
  end

  # API for workprogramm-app
  #
  namespace :years do
    params do
      requires :year, :type => Integer, :desc => 'Year number'
    end
    namespace ':year' do
      get 'specialities' do
        year.specialities.actual.gos3.as_json(
          :only => [:id, :title, :code],
          :methods => [:degree_text, :to_s]
        )
      end
      namespace 'specialities' do
        namespace ':speciality_id' do
          params do
            requires :speciality_id, :type => Integer, :desc => 'Speciality id'
          end
          get 'subspecialities' do
            year.specialities.actual.gos3.find(params[:speciality_id]).subspecialities.actual.as_json(
              :only => [:id, :title],
              :methods => [:education_form_text, :to_s, :department_abbr, :department_title, :subdepartment_abbr, :subdepartment_title, :info]
            )
          end
          namespace 'subspecialities' do
            namespace ':subspeciality_id' do
              params do
                requires :subspeciality_id, :type => Integer, :desc => 'Subspeciality id'
              end
              get 'disciplines' do
                year.specialities.actual.gos3.find(params[:speciality_id]).subspecialities.actual.find(params[:subspeciality_id]).disciplines.actual.as_json(
                  :only => [:title, :summ_srs, :summ_loading, :id, :cycle, :credit_units],
                  :methods => [:to_s, :semesters_info, :provided_subdepartment_info], :include => { :competences => { :only => [:index, :content] } }
                )
              end
            end
          end
        end
      end
    end
  end
end
