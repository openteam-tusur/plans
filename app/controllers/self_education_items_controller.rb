class SelfEducationItemsController < ApplicationController
  inherit_resources

  actions :all, :except => [:index, :show]

  belongs_to :year, :finder => :find_by_number! do
    belongs_to :speciality, :finder => :find_by_code! do
      belongs_to :subspeciality do
        belongs_to :discipline do
          belongs_to :work_programm
        end
      end
    end
  end

  has_scope :kind

  layout false
end
