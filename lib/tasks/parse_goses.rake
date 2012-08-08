# encoding: utf-8

require 'rake'
require 'open-uri'
require 'progress_bar'
require 'nokogiri'

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
  Subspeciality.all.each do |subspeciality|
    if subspeciality.gos?
      html = Nokogiri::HTML subspeciality.gos.html
      next if subspeciality.disciplines.empty?
      if table = html.css("blockquote table:contains('Наименование')").first
        puts "="*100
        puts "#{subspeciality.speciality.code} #{subspeciality.speciality.degree}  #{subspeciality.speciality.title} (#{subspeciality.gos})"
        tds = table.css("tr>td[2]").map(&:text).map{|text| text.gsub(/^[^[:alnum:]]+|[^[:alnum:]]+$/, '').gsub(/\r/, '') }
        subspeciality.disciplines.each do |discipline|
         if content = tds.grep(/\A#{discipline.title}/i).first
            didactic_unit = subspeciality.gos.didactic_units.find_or_initialize_by_discipline(discipline.title)
            content = tds[tds.index(content)+1] if content == discipline.title
            content.gsub!(/\A#{discipline.title}[^[:alnum:]]+/i, '')
            didactic_unit.update_attributes! :content => content if didactic_unit.new_record? || !didactic_unit.content?
            print "+"
          else
            print "."
          end
        end
        puts
      end
    end
  end
end
