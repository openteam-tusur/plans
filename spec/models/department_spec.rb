# encoding: utf-8
# == Schema Information
#
# Table name: departments
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  abbr       :string(255)
#  number     :integer
#  year_id    :integer
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  context_id :integer
#


require 'spec_helper'

describe Department do

  let(:department) { Department.new }
  describe "#chief" do
    it "for department fsu in year 2012" do
      department.stub(:abbr).and_return('ФСУ')
      department.chief(2012).full_name.should == "Сенченко Павел Васильевич"
    end

    it "for fsu, 2011" do
      department.stub(:abbr).and_return('ФСУ')
      department.chief(2011).should == Person.nil
    end
  end
end

