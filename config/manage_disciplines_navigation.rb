SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    subdepartments.each do |subdepartment|
      primary.item subdepartment.abbr, subdepartment.abbr, manage_subdepartment_disciplines_path(subdepartment), :highlights_on => ->(){ subdepartment == parent }
    end
    primary.dom_class = 'manage_disciplines'
  end
end
