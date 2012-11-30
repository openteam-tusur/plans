SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    Year.order(:number).each do |year|
      primary.item year.number, t('enter_year', :year => year.number), manage_year_scoped_specialities_path(year, :degree => year.specialities.pluck(:degree).uniq.sort.first), :highlights_on => ->(){ @year == year } do |sub_menu|
        year.specialities.pluck(:degree).uniq.sort.each do |degree|
          sub_menu.item degree,
                        t("activerecord.values.speciality.#{degree}"),
                        manage_year_scoped_specialities_path(year, :degree => degree),
                        :highlights_on => ->(){ @year == year && ((@speciality.present? && @speciality.degree == degree) || (params[:degree] == degree)) }

          sub_menu.dom_class = 'sub_menu'
        end
          sub_menu.item :statistic, t('statistics'), manage_year_statistics_path(year)
      end if year.specialities.any?
    end
    primary.dom_class = 'manage_specialities'
  end
end
