class Manage::ProgrammsController < Manage::ApplicationController
  inherit_resources

  actions :all, :except => :index

  belongs_to :year, :finder => :find_by_number! do
    belongs_to :speciality, :finder => :find_by_code! do
      belongs_to :subspeciality, :singleton => true
    end
  end

  layout false

  def destroy
    destroy! { render :file => 'manage/programms/show', :locals => { :resource => nil } and return }
  end
end