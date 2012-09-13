SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    %w(drafts reduxes checks_by_provided_subdivision checks_by_profiled_subdivision checks_by_graduated_subdivision checks_by_library checks_by_methodological_office checks_by_educational_office releases).each do |folder|
      primary.item folder.to_sym,
                   t("navigation.manage_messages.#{folder}")+"<span>#{Message.send(folder, current_user).unreaded.size}</span>",
                   manage_scoped_messages_path(:folder => folder),
                   :highlights_on => ->(){ params[:folder] == folder }
    end
    primary.dom_class = 'message_folders'
  end
end
