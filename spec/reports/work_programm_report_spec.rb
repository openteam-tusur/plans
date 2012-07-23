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
    context '1 курс' do
      before { report.discipline.should_receive(:loaded_courses).and_return([1]) }
      it { should == "1" }
    end
    context '1,2 курс' do
      before { report.discipline.should_receive(:loaded_courses).and_return([1, 2]) }
      it { should == '1, 2' }
    end
  end

  describe '#title_page_semesters' do
    subject { report.title_page_semesters }
    context '1 семестр' do
      before { report.discipline.should_receive(:loaded_semesters).and_return([1]) }
      it { should == '1' }
    end
    context '1,2 семестр' do
      before { report.discipline.should_receive(:loaded_semesters).and_return([1, 2]) }
      it { should == '1, 2' }
    end
  end

  describe '#title_page_semesters' do
    before { report.speciality_year.number = 2008 }
    its(:title_page_speciality_year) { should == 'Учебный план набора 2008 года и последующих лет' }
  end

  describe '#title_page_work_scheduling' do
    let(:scheduling) { report.title_page_work_scheduling }
    let(:semester) { Fabricate(:semester, :subspeciality => report.subspeciality) }
    subject { scheduling }
    before { report.discipline.loadings.create(:loading_kind => 'practice', :semester => semester, :value => 36) }
    before { report.discipline.loadings.create(:loading_kind => 'lecture', :semester => semester, :value => 24) }
    before { report.discipline.loadings.create(:loading_kind => 'exam', :semester => semester, :value => 10) }
    before { report.discipline.loadings.create(:loading_kind => 'srs', :semester => semester, :value => 10) }

    its(:semesters) { should == [1] }
    context 'аудиторные занятия' do
      describe '#lecture' do
        subject { scheduling.lecture }
        its(:hours) { should == { 1 => 24 } }
        its(:total) { should == 24 }
      end
      describe '#practice' do
        subject { scheduling.practice }
        its(:hours) { should == { 1 => 36 } }
      end
      describe '#classroom' do
        subject { scheduling.classroom }
        its(:hours) { should == { 1 => 60 } }
        its(:total) { should == 60 }
      end
    end
    context 'неаудиторные занятия' do
      describe '#srs' do
        subject { scheduling.srs }
        its(:hours) { should == { 1 => 10 } }
      end
      describe '#exam' do
        subject { scheduling.exam }
        context 'нагрузка совпадает' do
          before { report.discipline.summ_loading = 70 }
          its(:total) { should == 0 }
        end
        context 'нагрузка совпадает' do
          before { report.discipline.summ_loading = 80 }
          its(:total) { should == 10 }
        end
      end
    end
    describe '#total' do
      its('total.total') { should == 80 }
    end
  end

end
