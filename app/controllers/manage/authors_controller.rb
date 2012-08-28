class Manage::AuthorsController < Manage::ApplicationController
  inherit_resources
  defaults :resource_class => Person

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
    update! { manage_year_speciality_subspeciality_discipline_work_programm_author_path(@year, @speciality, @subspeciality, @discipline, @work_programm, resource) }
  end

  def create
    create! { manage_year_speciality_subspeciality_discipline_work_programm_author_path(@year, @speciality, @subspeciality, @discipline, @work_programm, resource) }
  end

  def destroy
    destroy! { render :nothing => true and return }
  end
end
