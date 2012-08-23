class Protocol < ActiveRecord::Base
  belongs_to :work_programm
  attr_accessible :number, :signed_on
  validates_presence_of :number, :signed_on, :on => :update
end
