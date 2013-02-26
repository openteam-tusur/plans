SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.item :messages,
                 t('navigation.main_manage_navigation.messages'),
                 manage_root_path,
                 :highlights_on => /messages|manage$/

    primary.item :specialities,
                 t('navigation.main_manage_navigation.specialities'),
                 manage_year_scoped_specialities_path(year = (Time.zone.today - 6.month).year, :degree => Year.find_by_number(year).specialities.pluck(:degree).uniq.sort.first),
                 :highlights_on => /year/

    primary.item :goses,
                 t('navigation.main_manage_navigation.goses'),
                 manage_goses_path,
                 :highlights_on => /gos/ if can? :manage, Gos

    primary.item :disciplines,
                 t('navigation.main_manage_navigation.disciplines'),
                 manage_subdepartment_disciplines_path(Subdepartment.actual.first),
                 :highlights_on => /disciplines/
  end
end
