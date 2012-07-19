
class WorkProgrammsController < ApplicationController
  inherit_resources
  respond_to :html
  respond_to :pdf, :only => :show

  belongs_to :year, :finder => :find_by_number! do
    belongs_to :speciality, :finder => :find_by_code! do
      belongs_to :subspeciality do
        belongs_to :discipline
      end
    end
  end

  def show
    show! do |format|
      format.pdf do
        wp = WorkProgrammReport.new.to_pdf(resource)
        send_data wp, :file_name => "rpd.pdf", :type => "application/pdf", :format => :pdf
      end
    end
  end
end
