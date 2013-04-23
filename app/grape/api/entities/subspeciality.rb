class API::Entities::Subspeciality < Grape::Entity
  expose :id
  expose :title
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
  expose :subdepartment, :using => API::Entities::Subdepartment
end
