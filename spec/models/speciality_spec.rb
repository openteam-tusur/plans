# encoding: utf-8

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
