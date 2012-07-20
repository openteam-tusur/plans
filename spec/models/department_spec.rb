# encoding: utf-8

require 'spec_helper'

describe Department do

  let(:department) { Department.new }
  describe "#chief" do
    it "for department fsu in year 2012" do
      department.stub(:abbr).and_return('ФСУ')
      department.chief(2012).name.should == "Сенченко Павел Васильевич"
    end

    it "for fsu, 2011" do
      department.stub(:abbr).and_return('ФСУ')
      department.chief(2011).should be_nil
    end
  end
end

