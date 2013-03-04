# encoding: utf-8

SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.item :disciplines,
                 t('navigation.main_manage_navigation.disciplines'),
                 manage_root_path,
                 :highlights_on => /disciplines|manage$/ if Subdepartment.consumed_by(current_user).any?

    #primary.item :messages,
                 #t('navigation.main_manage_navigation.messages'),
                 #manage_scoped_messages_path(:folder => :reduxes),
                 #:highlights_on => /messages/ if current_user.manager?

    primary.item :specialities,
                 t('navigation.main_manage_navigation.specialities'),
                 manage_year_scoped_specialities_path((year = Year.ordered.first), :degree => year.specialities.pluck(:degree).uniq.sort.first),
                 :highlights_on => /year/ if current_user.manager?

    primary.item :goses,
                 t('navigation.main_manage_navigation.goses'),
                 manage_goses_path,
                 :highlights_on => /gos/ if can? :manage, Gos
  end
end
