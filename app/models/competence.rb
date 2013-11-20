class Competence < ActiveRecord::Base
  attr_accessible :index, :content

  belongs_to :subspeciality
end
