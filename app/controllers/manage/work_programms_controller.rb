class Manage::WorkProgrammsController < Manage::ApplicationController
  inherit_resources

  belongs_to :year, :finder => :find_by_number! do
    belongs_to :speciality, :finder => :find_by_code! do
      belongs_to :subspeciality do
        belongs_to :discipline
      end
    end
  end

  respond_to :html, :json
  respond_to :pdf, :only => :show

  actions :all, :except => :index

  layout :get_layout

  before_filter :set_creator, :only => :create

  def get_layout
    return false if params[:action] != 'show'
    'manage'
  end

  custom_actions :resource => [
                   :edit_purpose,
                   :get_didactic_units,
                   :get_event_actions,
                   :get_purpose,
                   :get_related_disciplines,
                   :return_to_author,
                   :shift_up
                 ]

  helper_method :title_page, :sign_page, :purposes_and_tasks_page

  def new
    new! { render :new, :layout => false and return }
  end

  def create
    create! do |success, failure|
      success.html { render :text => resource_path and return }
      failure.html { render :new and return }
    end
  end

  def edit
    edit! { render :edit, :layout => false and return }
  end

  def update
    update! {
      if params[:work_programm].has_key?(:purpose)
        redirect_to [:get_purpose, :manage, association_chain, resource].flatten and return
      else
        redirect_to [:get_related_disciplines, :manage, association_chain, resource].flatten and return
      end
    }
  end

  def destroy
    destroy! { render :nothing => true, :layout => false and return }
  end

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

  def get_related_disciplines
    render :file => 'manage/related_disciplines/index',
      :locals => { :collection => resource.related_disciplines },
      :layout => false and return
  end

  def edit_purpose
    edit! { render :partial => 'edit_purpose', :layout => false and return }
  end

  def get_purpose
    render :partial => 'purpose', :locals => { :purpose => resource.purpose }, :layout => false and return
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
