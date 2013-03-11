SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    available_years.each do |year|
      if year == current_year
        primary.item year.number, t('enter_year', :year => year.number),
          rpz_year_subspecialities_path(year, :education_form => current_education_form),
          :highlights_on => ->(){ year == current_year }
      else
        primary.item year.number, t('enter_year', :year => year.number),
          rpz_year_subspecialities_path(year, :education_form => current_education_form),
          :highlights_on => ->(){ year == current_year }
      end
    end
    primary.dom_class = 'manage_specialities'
  end
end
