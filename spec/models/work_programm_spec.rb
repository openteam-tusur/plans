# encoding: utf-8
# == Schema Information
#
# Table name: work_programms
#
#  id            :integer          not null, primary key
#  year          :integer
#  discipline_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  purpose       :text
#  vfs_path      :string(255)
#  state         :string(255)
#  creator_id    :integer
#


require 'spec_helper'

describe WorkProgramm do
  subject {Fabricate(:discipline).work_programms.create(:year => 2012)}
  describe "#after_create" do
    its(:purpose)  {should == "Целью изучения дисциплины «Учебная дисциплина» является"}
  end


end
