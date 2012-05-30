# encoding: utf-8

require 'spec_helper'

describe Subdepartment do
  describe '.name_by_number' do
    it { Subdepartment.name_by_number(1).should =~ /Радиоэлектроники и защиты информации\s+/ }
    it { Subdepartment.name_by_number(37).should =~ /Управление инновациями\s+/ }
  end

  describe '.find_or_create_by_year_and_number' do
    let(:subdepartment) { Subdepartment.find_or_create_by_year_and_number(2012, 1) }
    subject { subdepartment }

    its(:abbr) { should == "РЗИ" }
    its(:title) { should == "Радиоэлектроники и защиты информации" }

    describe '#department' do
      let(:department) { subdepartment.department }
      subject { department }

      its(:abbr) { should == 'РТФ' }

      describe '#year' do
        subject { department.year }

        its(:number) { should == 2012 }
      end
    end
  end
end
