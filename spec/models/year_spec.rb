# == Schema Information
#
# Table name: years
#
#  id         :integer          not null, primary key
#  number     :integer
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Year do
  it { should have_many :specialities }
  it { should have_many :subspecialities }
  it { should validate_presence_of :number }
end
