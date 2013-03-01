# encoding: utf-8

desc "Удаление неактуальных записей"
task :clean => :environment do
  Year.where('deleted_at IS NOT NULL').delete_all
  Speciality.where('deleted_at IS NOT NULL').delete_all
  Subspeciality.where('deleted_at IS NOT NULL').delete_all
  Discipline.where('deleted_at IS NOT NULL').delete_all
  Semester.where('deleted_at IS NOT NULL').delete_all
end
