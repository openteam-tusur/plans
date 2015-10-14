require 'rake'
require 'open-uri'
require 'progress_bar'
require 'nokogiri'
require 'yaml'

NEWFGOS = /\d{2}[.]\d{2}[.]\d{2}/

desc 'Парсинг содержимого папки в файл specialities.yml'
task :parse_files => :environment do
  dir = Dir.glob("data/2015/plans/*/*")
  puts dir.count.to_s + "файла в работе"
  rups = dir.collect do |path|
    file = File.open(path)
    xml = Nokogiri::XML file
    code  = file.path.match(NEWFGOS).to_s
    speciality = get_title xml
    subspeciality_title = get_subspeciality_title xml
    subdepartment = get_subdepartment xml
    file.close
    {speciality: speciality, code: code, subdepartment: subdepartment, title: subspeciality_title}
  end
  superhash = rups.group_by{|s| s[:speciality]}.map do |speciality, array|
    s = array.map{|n| {"subdepartment" => n[:subdepartment], "title" => n[:title] } }
    { ""  => { "code" => array.first[:code], "title" => speciality, "subspecialities" =>  s }}
  end
  file = File.open('specialities.yml', 'w')
  file.write superhash.to_yaml(:Indent => 4, :UseHeader => false)
  file.close
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
