# encoding: utf-8
# == Schema Information
#
# Table name: disciplines
#
#  id               :integer          not null, primary key
#  title            :string(255)
#  cycle            :string(255)
#  subspeciality_id :integer
#  subdepartment_id :integer
#  deleted_at       :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  summ_loading     :integer
#  summ_srs         :integer
#  cycle_code       :string(255)
#  cycle_id         :string(255)
#  kind             :string(255)
#


require 'spec_helper'

describe Discipline do
  it { should have_many :checks }
  it { should have_many :loadings }
  it { should validate_presence_of :title }
  it { should validate_presence_of :subspeciality }
  it { should validate_presence_of :subdepartment }
  it { should belong_to :subspeciality }
  it { should belong_to :subdepartment }
end
