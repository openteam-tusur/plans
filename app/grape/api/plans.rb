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
end
