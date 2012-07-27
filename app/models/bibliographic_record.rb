class BibliographicRecord < ActiveRecord::Base
  belongs_to :work_programm
  attr_accessible :kind, :place, :text, :url
end
