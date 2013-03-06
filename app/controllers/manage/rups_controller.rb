# encoding: utf-8

class Manage::RupsController < ApplicationController
  def index
    @rups = {}
    [2007, 2008, 2009].each do |year_number|
      year = Year.find_by_number(year_number)
      Subspeciality.education_form.values.each do |education_form|
        subspecialities = year.subspecialities.where(education_form: education_form).where('subspecialities.deleted_at is null').group_by(&:speciality)
        if subspecialities.any?
          @rups[year] ||= []
          @rups[year] << {education_form => subspecialities}
        end
      end
    end
    render layout: false
  end
end
