class Manage::PeopleController < Manage::ApplicationController
  inherit_resources

  actions :all, :except => :index

  belongs_to :year, :finder => :find_by_number! do
    belongs_to :speciality, :finder => :find_by_code! do
      belongs_to :subspeciality do
        belongs_to :discipline do
          belongs_to :work_programm, :optional => true
        end
      end
    end
  end

  layout false

  def update
    update! do |success, failure|
      success.html { redirect_to manage_year_speciality_subspeciality_discipline_work_programm_person_path(@year, @speciality, @subspeciality, @discipline, @work_programm, resource) }
      failure.html { render :new and return }
    end
  end

  def create
    create! do |success, failure|
      success.html { redirect_to manage_year_speciality_subspeciality_discipline_work_programm_person_path(@year, @speciality, @subspeciality, @discipline, @work_programm, resource) }
      failure.html { render :new and return }
    end
  end

  def destroy
    destroy! { render :nothing => true and return }
  end
end
