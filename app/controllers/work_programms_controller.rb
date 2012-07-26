class WorkProgrammsController < ApplicationController
  inherit_resources

  respond_to :html, :json
  respond_to :pdf, :only => :show

  belongs_to :year, :finder => :find_by_number! do
    belongs_to :speciality, :finder => :find_by_code! do
      belongs_to :subspeciality do
        belongs_to :discipline
      end
    end
  end

  helper_method :title_page

  def show
    show! do |format|
      format.pdf do
        render :pdf => "work_programm_#{resource.id}.pdf",
               :template => 'reports/work_programm.html.erb'
      end
    end
  end

  private
    def title_page
      TitlePage.new(@work_programm)
    end
end
