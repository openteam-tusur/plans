
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

  def show
    show! do |format|
      format.pdf do
        wp = WorkProgrammReport.new(:page_size => 'A4', :left_margin => 50, :right_margin => 25, :top_margin => 25, :bottom_margin => 25).to_pdf(resource)
        send_data wp, :file_name => "rpd.pdf", :type => "application/pdf", :format => :pdf
      end
    end
  end
end
