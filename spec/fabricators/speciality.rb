# encoding: utf-8

Fabricator(:speciality) do
  year { Year.find_or_create_by_number(2012) }
  code '123123'
  title 'Специальность подготовки'
  degree 'benchor'
end
