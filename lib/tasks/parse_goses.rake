# encoding: utf-8

require 'rake'
require 'open-uri'
require 'progress_bar'

task :parse_goses => :environment do
  goses = Gos.where(:html => nil)
  bar = ProgressBar.new(goses.count)
  goses.each do |gos|
    html = nil
    gos.html = begin
                 html = open("http://www.edu.ru/db/portal/spe/os_zip/#{gos.code}_#{gos.approved_on.year}.html").read
               rescue
                 begin
                   html = open("http://www.edu.ru/db/portal/spe/os_okso_zip/#{gos.code}_#{gos.approved_on.year}.html").read
                 rescue
                   puts gos.speciality_code
                 end
               end
    gos.save!
    bar.increment!
  end
end
