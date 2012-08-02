class AppendixesController < ApplicationController
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
    create! { [@year, @speciality, @subspeciality, @discipline, @work_programm] }
  end

  def update
    update! { [@year, @speciality, @subspeciality, @discipline, @work_programm] }
  end

  def destroy
    destroy! { [@year, @speciality, @subspeciality, @discipline, @work_programm] }
  end
end
