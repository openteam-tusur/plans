class WorkProgrammsController < ApplicationController
  inherit_resources

  respond_to :html, :json
  respond_to :pdf, :only => :show

  layout false, :except => [:index, :show]

  belongs_to :year, :finder => :find_by_number! do
    belongs_to :speciality, :finder => :find_by_code! do
      belongs_to :subspeciality do
        belongs_to :discipline
      end
    end
  end

  helper_method :title_page, :sign_page, :purposes_and_tasks_page

  def show
    show! do |format|
      format.pdf do
        render  :pdf => "work_programm_#{resource.id}.pdf",
                :template => 'reports/work_programm.html.erb',
                :show_as_html => params[:debug],
                :outline => false,
                :enable_javascript => true,
                :margin => { :top       => 10,
                             :bottom    => 10,
                             :left      => 25,
                             :right     => 10 },
                :footer => { :html => { :template => 'reports/work_programm_footer.pdf.erb' }}
      end
    end
  end

  private
    def title_page
      TitlePage.new(@work_programm)
    end

    def sign_page
      SignPage.new(@work_programm)
    end

    def purposes_and_tasks_page
      PurposesAndTasksPage.new(@work_programm)
    end
end
