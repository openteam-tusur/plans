class AppendixItem < ActiveRecord::Base
  attr_accessible :description

  belongs_to :appendix

  validates_presence_of :description
end
