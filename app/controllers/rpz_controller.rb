class RpzController < ActionController::Base
  protect_from_forgery
  layout 'public'

  def index
    @grouped_subspecialities = Subspeciality.actual.where('subspecialities.education_form' => ['postal', 'part-time']).includes([:speciality, :year]).order('specialities.code').group_by(&:year)
  end

  def show
    @subspeciality = Subspeciality.find(params[:id])
  end
end

