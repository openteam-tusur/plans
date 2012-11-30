# encoding: utf-8
# == Schema Information
#
# Table name: specialities
#
#  id             :integer          not null, primary key
#  code           :string(255)
#  title          :string(255)
#  degree         :string(255)
#  year_id        :integer
#  deleted_at     :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  gos_generation :string(255)
#


require 'spec_helper'

describe Speciality do
  it { should have_many :subspecialities }
  it { should validate_presence_of :code }
  it { should validate_presence_of :title }
  it { should validate_presence_of :degree }
  it { should validate_presence_of :year }
  it { should belong_to :year }
  let(:subspeciality) { Fabricate(:subspeciality) }
  let(:speciality) { subspeciality.speciality }

  it "when set deleted_at" do
    speciality.update_attribute(:deleted_at, Time.now)
    subspeciality.deleted_at.should_not nil
  end

end
