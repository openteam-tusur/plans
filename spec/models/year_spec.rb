require 'spec_helper'

describe Year do
  it { should have_many :departments }
  it { should have_many :subdepartments }
  it { should have_many :specialities }
  it { should have_many :subspecialities }
  it { should validate_presence_of :number }

  let(:subspeciality) { Fabricate(:subspeciality) }

  it "when set deleted_at" do
    subspeciality.speciality.year.update_attribute(:deleted_at, Time.now)
    subspeciality.reload.deleted_at.should_not be_nil
    subspeciality.speciality.deleted_at.should_not be_nil
    subspeciality.subdepartment.deleted_at.should_not be_nil
    subspeciality.subdepartment.department.deleted_at.should_not be_nil
  end
end
