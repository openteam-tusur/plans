# encoding: utf-8

desc "Импорт списка факультетов и кафедр"
task :import => :environment do
  year_number = File.basename(ENV['from'], '.yml')
  year = Year.find_by_number(year_number)

  YAML.load_file(ENV['from']).each do |department|
    year.departments.create! department
  end
end
