class Publication < ActiveRecord::Base
  attr_accessible :publication_kind, :text, :url, :work_programm_id

  belongs_to :work_programm

  alias_attribute :to_s, :text

  has_enum :publication_kind
end
