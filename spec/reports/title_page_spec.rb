# encoding: utf-8

require 'spec_helper'

describe TitlePage do
  let(:page) { TitlePage.new(Fabricate(:work_programm)) }

  delegate :discipline, :to => :page
  delegate :loadings, :to => :discipline
  delegate :checks, :to => :discipline

  subject { page }

  let(:semester) { Fabricate(:semester, :subspeciality => page.subspeciality) }
  let(:semester2) { Fabricate(:semester, :subspeciality => page.subspeciality, :number => 2) }

  its(:date_line) { should == '«____» _____________________ 2012 г.' }
  its(:discipline_title) { should == 'Учебная дисциплина (ЕСН.Ф)' }

  describe '#loaded_courses' do
    before { page.should_receive(:loaded_semesters).and_return(semesters) }
    subject { page.loaded_courses }
    context 'semesters: 1' do
      let(:semesters)  { [1] }
      it { should == [1] }
    end
    context 'semesters: 1, 2' do
      let(:semesters)  { [1, 2] }
      it { should == [1] }
    end
    context 'semesters: 1, 2, 3' do
      let(:semesters)  { [1, 2, 3] }
      it { should == [1, 2] }
    end
    context 'semesters: 1, 2, 3, 4' do
      let(:semesters)  { [1, 2, 3, 4] }
      it { should == [1, 2] }
    end
  end

  its(:speciality_title) { should == '123123 Специальность подготовки' }

  describe '#department_title' do
    subject { page.department_title }
    context 'Факультет систем управления' do
      before { page.department.title = 'Факультет систем управления' }
      it { should == 'Систем управления' }
    end
    context 'Юридический факультет' do
      before { page.department.title = 'Юридический факультет' }
      it { should == 'Юридический' }
    end
  end

  its(:subdepartment_title) { should == 'Обучающая' }

  describe '#courses' do
    subject { page.courses }
    context '1 курс' do
      before { page.should_receive(:loaded_courses).and_return([1]) }
      it { should == "1" }
    end
    context '1,2 курс' do
      before { page.should_receive(:loaded_courses).and_return([1, 2]) }
      it { should == '1, 2' }
    end
  end

  describe '#semesters' do
    subject { page.semesters }
    context '1 семестр' do
      before { page.should_receive(:loaded_semesters).and_return([1]) }
      it { should == '1' }
    end
    context '1,2 семестр' do
      before { page.should_receive(:loaded_semesters).and_return([1, 2]) }
      it { should == '1, 2' }
    end
  end

  describe '#semesters' do
    before { page.speciality.year.number = 2008 }
    its(:speciality_year) { should == 'Учебный план набора 2008 года и последующих лет' }
  end

  describe '#scheduling' do
    let(:scheduling) { page.scheduling }
    subject { scheduling }
    before { loadings.create(:kind => 'practice', :semester => semester, :value => 36) }
    before { loadings.create(:kind => 'lecture', :semester => semester, :value => 24) }
    before { loadings.create(:kind => 'exam', :semester => semester, :value => 10) }
    before { loadings.create(:kind => 'srs', :semester => semester, :value => 10) }

    its(:loaded_semesters) { should == [1] }

    context 'аудиторные занятия' do
      describe '#lecture' do
        subject { scheduling.lecture }
        its(:hours) { should == { 1 => 24 } }
        its(:total) { should == 24 }
        describe '#to_a' do
          before { loadings.create(:kind => 'crs', :semester => semester2, :value => 7) }
          subject { scheduling.lecture.to_a }
          it { should == ["Лекции", 24, 24, "-"] }
        end
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
          before { discipline.summ_loading = 70 }
          its(:total) { should == 0 }
        end
        context 'нагрузка совпадает' do
          before { discipline.summ_loading = 80 }
          its(:total) { should == 10 }
        end
      end
    end
    describe '#total' do
      its('total.total') { should == 80 }
    end
  end

  describe '#checks' do
    subject { page.checks }
    context 'зачёт в 1 семестре' do
      before { checks.create :kind => 'end_of_term', :semester => semester}
      it { should == {"Зачет" => "1 семестр"}}
    end
    context 'курсовой проект в 1, 2 семестре' do
      before { checks.create :kind => 'course_projecting', :semester => semester }
      before { checks.create :kind => 'course_work', :semester => semester2 }
      it { should == {'Диф. зачет' => '1, 2 семестр'}}
    end
  end

  its (:year_line) { should == '2012' }
end
