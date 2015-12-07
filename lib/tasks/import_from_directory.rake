require 'open-uri'
require 'progress_bar'

desc 'synchronize chairs and departments with directory'
task :import_structure => :environment do
  faculties = JSON.parse(open("#{Settings['directory.url']}/api/structure").read)
  bar = ProgressBar.new(faculties.count)
  faculties.each do |faculty|
    department = Department.where(abbr: faculty['abbr']).first_or_initialize
    department.title = faculty['title']
    department.save
    faculty['chairs'].each do |chair|
      subdepartment = Subdepartment.where(number: chair['number']).first_or_initialize
      subdepartment.department = department
      subdepartment.title = chair['title']
      subdepartment.abbr = chair['abbr']
      subdepartment.save!
    end
    bar.increment!
  end

end
