
# encoding: utf-8

require 'spec_helper'

describe Discipline do
  it { should have_many :checks }
  it { should validate_presence_of :title }
  it { should validate_presence_of :subspeciality }
  it { should validate_presence_of :subdepartment }
  it { should belong_to :subspeciality }
  it { should belong_to :subdepartment }

  let(:check) { Fabricate(:check) }

  it "when set deleted_at" do
    check.discipline.update_attribute(:deleted_at, Time.now)
    check.reload.deleted_at.should_not be_nil
  end

end
