Fabricator(:speciality) do
  year { Year.find_or_create_by_number(2012) }
  code "123123"
  title "Speciality title"
  degree "benchor"
end
