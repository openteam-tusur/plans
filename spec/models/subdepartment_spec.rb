#encoding: utf-8

require 'spec_helper'

describe Subdepartment do

  let(:subdepartment) { Subdepartment.new }

  describe "#chief" do
    it "for subdepartment number 7 in year 2012" do
      subdepartment.stub(:number).and_return(7)
      subdepartment.chief(2012).name.should == "Ехлаков Юрий Поликарпович"
    end

    it "for aoi, 2011" do
      subdepartment.stub(:number).and_return(7)
      subdepartment.chief(2011).should == Person::NIL
    end

  end

end
