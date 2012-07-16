Fabricator(:department) do
  year { Year.find_or_create_by_number(2012) }
  title "Department"
  abbr "D"
  number 1
end
