#encoding: utf-8
# == Schema Information
#
# Table name: subdepartments
#
#  id            :integer          not null, primary key
#  title         :string(255)
#  abbr          :string(255)
#  number        :integer
#  department_id :integer
#  deleted_at    :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#


require 'spec_helper'

describe Subdepartment do

  let(:subdepartment) { Subdepartment.new }

  describe "#chief" do
    it "for subdepartment number 7 in year 2012" do
      subdepartment.stub(:number).and_return(7)
      subdepartment.chief(2012).full_name.should == "Ехлаков Юрий Поликарпович"
    end

    it "for aoi, 2011" do
      subdepartment.stub(:number).and_return(7)
      subdepartment.chief(2011).should == Person.nil
    end

  end

end
