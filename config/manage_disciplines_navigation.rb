SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    subdepartment_abbrs.each do |subdepartment_abbr|
      primary.item subdepartment_abbr, subdepartment_abbr, manage_subdepartment_abbr_disciplines_path(subdepartment_abbr), :highlights_on => ->(){ params[:subdepartment_abbr] == subdepartment_abbr }
    end
    primary.dom_class = 'manage_disciplines'
  end
end
