# encoding: utf-8

require 'progress_bar'
require 'nokogiri'
require 'timecop'
require 'memoist'
require 'fileutils'

require File.expand_path '../../importer/year_importer', __FILE__
require File.expand_path '../../importer/plan_importer', __FILE__
require File.expand_path '../../importer/discipline_importer', __FILE__
require File.expand_path '../../importer/discipline_xml', __FILE__

def refresh(object)
  object.deleted_at = nil
end

def time_of_sync
  @time_of_sync ||= DateTime.now
end

def move_to_trash(*model_names)
  options = model_names.extract_options!
  [*model_names].each do |model_name|
    if options[:object]
      scope = options[:object].send(model_name)
    else
      scope = model_name.to_s.classify.constantize.scoped
    end
    scope.update_all(:deleted_at => time_of_sync)
  end
end

desc "Форсировать полный повторный импорт"
task :force_sync => :environment do
  move_to_trash :year, :speciality, :subspeciality, :semester, :discipline
  Subspeciality.update_all :plan_digest => nil, :file_path => nil
  Loading.delete_all
  Check.delete_all
end

desc "Синхронизация справочников"
task :sync => :environment do
  move_to_trash :year, :speciality, :subspeciality
  Dir.glob("data/*").sort.each do |folder|
    year_number = File.basename(folder)
    YearImporter.new(year_number).import
  end
end

desc "Загрузка учебного плана"
task :import_plan, [:path]=> :environment do |task, args|
  PlanImporter.new(args.path, :force => true).import
end
