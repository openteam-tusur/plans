# encoding: utf-8

namespace :clean do
  desc "Удаление неактуальных записей"
  task :subspecialities => :environment do
    Subspeciality.where('deleted_at IS NOT NULL').destroy_all
  end
end
