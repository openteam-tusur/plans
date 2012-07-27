# encoding: utf-8

require 'spec_helper'

describe WorkProgramm do
  subject {Fabricate(:discipline).work_programms.create(:year => 2012)}
  describe "#after_create" do
    its(:purpose)  {should == "Целью изучения дисциплины «Учебная дисциплина» является"}
  end


end
