SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    available_years.each do |year|
      if year == current_year
        primary.item year.number, t('enter_year', :year => year.number),
          rpz_year_subspecialities_path(year, :education_form => current_education_form),
          :highlights_on => ->(){ year == current_year } do |sub_menu|

          year.degrees(current_education_form).each do |degree|
            sub_menu.item degree,
                          Speciality.degree.find_value(degree).text,
                          rpz_year_subspecialities_path(year, :degree => degree, :education_form => current_education_form),
                          :highlights_on => -> { current_degree == degree }
          end
        end
      else
        primary.item year.number, t('enter_year', :year => year.number),
          rpz_year_subspecialities_path(year, :degree => year.degrees(current_education_form).first, :education_form => current_education_form),
          :highlights_on => ->(){ year == current_year }
      end
    end
    primary.dom_class = 'manage_specialities'
  end
end
