# encoding: utf-8

SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    Subspeciality.education_form.values.each do |education_form|
      primary.item education_form, education_form.text, rpz_year_subspecialities_path(:year_id => '2007', :degree => 'specialty', :education_form => education_form),
        :highlights_on => -> {education_form == current_education_form}
    end
  end
end
