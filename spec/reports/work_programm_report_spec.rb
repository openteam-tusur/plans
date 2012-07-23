# encoding: utf-8

require 'spec_helper'

describe WorkProgrammReport do
  let(:report) { WorkProgrammReport.new.tap {|report| report.work_programm = Fabricate(:work_programm)} }
  subject { report }

  its(:title_page_date_line) { should == '«____» _____________________ 2012 г.' }
  its(:title_page_discipline) { should == 'Учебная дисципина (ЕСН.Ф.1)' }

  describe '#title_page_speciality_kind' do
    subject { report.title_page_speciality_kind }
    context 'специалитет' do
      before { report.speciality.degree = 'specialty' }
      it { should == 'Специальность' }
    end
    context 'бакалвриат' do
      before { report.speciality.degree = 'benchor' }
      it { should == 'Направление' }
    end
    context 'магистратура' do
      before { report.speciality.degree = 'magistracy' }
      it { should == 'Направление' }
    end
  end

  its(:title_page_speciality) { should == '123123 Специальность подготовки' }

  describe '#title_page_department' do
    subject { report.title_page_department }
    context 'Факультет систем управления' do
      before { report.department.title = 'Факультет систем управления' }
      it { should == 'Систем управления' }
    end
    context 'Юридический факультет' do
      before { report.department.title = 'Юридический факультет' }
      it { should == 'Юридический' }
    end
  end

  its(:title_page_subdepartment) { should == 'Обучающая' }


  describe '#title_page_courses' do
    subject { report.title_page_courses }
    context "1 курс" do
      before { report.discipline.should_receive(:loaded_courses).and_return([1]) }
      it { should == "1" }
    end
    context "1,2 курс" do
      before { report.discipline.should_receive(:loaded_courses).and_return([1, 2]) }
      it { should == "1, 2" }
    end
  end

  describe "#title_page_semesters" do
    subject { report.title_page_semesters }
    context "1 семестр" do
      before { report.discipline.should_receive(:loaded_semesters).and_return([1]) }
      it { should == "1" }
    end
    context "1,2 семестр" do
      before { report.discipline.should_receive(:loaded_semesters).and_return([1, 2]) }
      it { should == "1, 2" }
    end
  end

  describe "#title_page_semesters" do
    before { report.speciality_year.number = 2008 }
    its(:title_page_speciality_year) { should == 'Учебный план набора 2008 года и последующих лет' }
  end
end
