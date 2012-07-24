# encoding: utf-8

Fabricator(:department) do
  year { Year.find_or_create_by_number(2012) }
  title "Факультет Обучения"
  abbr "ФО"
  number 1
end
