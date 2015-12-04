require 'rake'
require 'open-uri'
require 'progress_bar'
require 'nokogiri'
require 'yaml'

NEWFGOS = /\d{2}[.]\d{2}[.]\d{2}/

desc 'Парсинг содержимого папки в файл specialities.yml'
task :parse_files => :environment do
  bar = ProgressBar.new((2015..2016).count)
  (2015..2016).each do |year|
    dir = Dir.glob("data/#{year}/plans/*/*") + Dir.glob("data/#{year}/plans/*")
    puts dir.count.to_s + "файла в работе"
    rups = dir.collect do |path|
      next unless path.match(/[.]xml$/)
      file = File.open(path)
      xml = Nokogiri::XML file
      code  = file.path.match(NEWFGOS).to_s
      speciality = get_title xml
      subspeciality_title = get_subspeciality_title xml
      subdepartment = get_subdepartment xml
      file.close
      if Subspeciality.where(title: subspeciality_title, file_path: path).empty?
        puts "file #{path} parsed into #{subspeciality_title}"
        {speciality: speciality, code: code, subdepartment: subdepartment, title: subspeciality_title}
      end
    end

    superhash = rups.compact.group_by{|s| s[:speciality]}.map do |speciality, array|
      s = array.map{|n| {"subdepartment" => n[:subdepartment], "title" => n[:title] } }
      { ""  => { "code" => array.first[:code], "title" => speciality, "subspecialities" =>  s }}
    end
    file = File.open("data/specialities_#{year}.yml", 'w')
    file.write superhash.to_yaml(:Indent => 4, :UseHeader => false)
    file.close
    bar.increment!
  end
end

def get_title(xml)
  result = xml.at_css("Специальности Специальность")["Название"]
  %w(Направление подготовки магистра " -).each {|w| result.gsub!(w, "")}
  result.gsub(NEWFGOS, '').squish
end


def get_subspeciality_title(xml)
  result = xml.css("Специальности Специальность")[1]["Название"]
  %w(Магистерская программа Программа академической магистратуры - ").each {|w| result.gsub!(w, "")}
  result.squish
end

def get_subdepartment(xml)
  number = xml.at_css("Титул")["КодКафедры"]
  Subdepartment.find_by_number(number).abbr
end
