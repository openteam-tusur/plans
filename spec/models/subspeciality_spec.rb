require 'spec_helper'

describe Subspeciality do
  it { should belong_to :subdepartment }
  it { should belong_to :speciality }
  it { should validate_presence_of :title }
  it { should validate_presence_of :speciality }
  it { should validate_presence_of :subdepartment }
  it { should have_many :disciplines }
  it { should have_one :programm }

  let(:discipline) { Fabricate(:discipline) }

  it "when set deleted_at" do
    discipline.subspeciality.update_attribute(:deleted_at, Time.now)
    discipline.reload.deleted_at.should_not be_nil
  end
end
