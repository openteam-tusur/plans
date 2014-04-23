class API::Entities::Subspeciality < Grape::Entity
  expose :id
  expose :title
  expose :approved_on
  expose :year do |subspeciality, options|
    subspeciality.year.number
  end
  expose :year do |subspeciality, options|
    subspeciality.year.number
  end
  expose :education_form do |subspeciality, options|
    { name: subspeciality.education_form, title: subspeciality.education_form_text }
  end
  expose :speciality, :using => API::Entities::Speciality

  # TODO: subdepartment to graduated_subdepartment
  expose :subdepartment, :using => API::Entities::Subdepartment
end
