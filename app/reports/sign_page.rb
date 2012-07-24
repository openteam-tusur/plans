class SignPage < Page
  def authors_header
    I18n.t('pluralize.author', :count => work_programm.authors.size)
  end

  def authors
    work_programm.authors.map do |author|
      ["#{author.post}\n#{author.science_post}", "______________", author.short_name]
    end
  end
end
