
# encoding: utf-8

require 'spec_helper'

describe Discipline do
  it { should have_many :checks }
  it { should have_many :loadings }
  it { should validate_presence_of :title }
  it { should validate_presence_of :subspeciality }
  it { should validate_presence_of :subdepartment }
  it { should belong_to :subspeciality }
  it { should belong_to :subdepartment }

  let(:check) { Fabricate(:check) }

  it "when set deleted_at" do
    loading = check.discipline.loadings.create(:semester => check.semester, :value => 10, :loading_kind => 'lecture')
    check.discipline.update_attribute(:deleted_at, Time.now)
    check.reload.deleted_at.should_not be_nil
    loading.reload.deleted_at.should_not be_nil
  end

  describe "#loaded_courses" do
    let(:discipline) { Discipline.new }
    # slecial for sev
    it "when semesters 1" do
      discipline.should_receive(:loaded_semesters).and_return([1])
      discipline.loaded_courses.should == [1]
    end

    it "when semesters 1,2" do
      discipline.should_receive(:loaded_semesters).and_return([1, 2])
      discipline.loaded_courses.should == [1]
    end

    it "when semesters 2,3" do
      discipline.should_receive(:loaded_semesters).and_return([2,3])
      discipline.loaded_courses.should == [1,2]
    end

    it "when semesters 1-8" do
      discipline.should_receive(:loaded_semesters).and_return((1..8).to_a)
      discipline.loaded_courses.should == (1..4).to_a
    end

  end

end
