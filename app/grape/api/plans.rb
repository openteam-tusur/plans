# encoding: utf-8

class API::Plans < Grape::API
  version 'v1', :using => :path
  rescue_from :all
  format :json

  get :ping do
    :ok
  end

  namespace :disciplines do
    helpers do
      def subspeciality
        @subspeciality ||= Subspeciality.find(params[:supspeciality_id])
      end

      def semester
        subspeciality.semesters.find_by_number(params[:semester])
      end
    end

    params do
      requires :supspeciality_id, :type => Integer, :desc => "id of subspeciality"
    end

    namespace ":supspeciality_id" do
      desc 'Retrieve subspeciality disciplines in semester'
      params do
        requires :semester, :type => Integer, :desc => "number of semester"
      end
      get ":semester" do
        present semester.disciplines, :with => API::Entities::Discipline, :semester => semester
      end
    end
  end
end
