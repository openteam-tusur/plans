class Manage::AppendixesController < Manage::ApplicationController
  inherit_resources

  actions :all, :except => [:index, :show]

  belongs_to :year, :finder => :find_by_number! do
    belongs_to :speciality, :finder => :find_by_code! do
      belongs_to :subspeciality do
        belongs_to :discipline do
          belongs_to :work_programm do
            belongs_to :exercise, :self_education_item, :polymorphic => true, :singleton => true
          end
        end
      end
    end
  end

  def create
    create! { polymorphic_url([:manage, @year, @speciality, @subspeciality, @discipline, @work_programm], :anchor => 'paragraph2') }
  end

  def update
    update! { polymorphic_url([:manage, @year, @speciality, @subspeciality, @discipline, @work_programm], :anchor => 'paragraph2') }
  end

  def destroy
    destroy! { polymorphic_url([:manage, @year, @speciality, @subspeciality, @discipline, @work_programm], :anchor => 'paragraph2') }
  end
end
