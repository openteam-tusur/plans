# encoding: utf-8

Fabricator(:subspeciality) do
  speciality
  title "Направление обучения"
  subdepartment
  department
  education_form 'full-time'
end
