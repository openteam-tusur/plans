# == Schema Information
#
# Table name: subspecialities
#
#  id                         :integer          not null, primary key
#  title                      :string(255)
#  speciality_id              :integer
#  subdepartment_id           :integer
#  deleted_at                 :datetime
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  graduated_subdepartment_id :integer
#  department_id              :integer
#  education_form             :string(255)
#  file_path                  :text
#  plan_digest                :string(255)
#  reduced                    :string(255)
#

require 'spec_helper'

describe Subspeciality do
  it { should belong_to :subdepartment }
  it { should belong_to :speciality }
  it { should validate_presence_of :title }
  it { should validate_presence_of :speciality }
  it { should validate_presence_of :subdepartment }
  it { should have_many :disciplines }
  it { should have_one :programm }
end
