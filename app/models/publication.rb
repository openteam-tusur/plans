class Publication < ActiveRecord::Base
  attr_accessible :publication_kind, :text, :url, :work_programm_id

  belongs_to :work_programm

  validates_presence_of :text

  has_enum :publication_kind

  def to_s
    "#{text}".tap { |s| s << ". URL: #{url}"  if url? }
  end
end
