class Manage::WorkProgrammsController < Manage::ApplicationController
  inherit_resources

  custom_actions :resource => [:get_didactic_units, :get_event_actions, :shift_up, :return_to_author]

  before_filter :set_creator, :only => :create

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

  def get_didactic_units
    render :partial => 'manage/work_programms/didactic_units', :layout => false
  end

  def get_event_actions
    render :partial => 'manage/work_programms/event_actions', :layout => false
  end

  def shift_up
    resource.message_text = params[:work_programm][:message_text]
    resource.shift_up!
    redirect_to [:manage, association_chain, resource].flatten
  end

  def return_to_author
    resource.message_text = params[:work_programm][:message_text]
    resource.return_to_author!
    redirect_to [:manage, association_chain, resource].flatten
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

    def set_creator
      resource.creator_id = current_user.id
    end
end
