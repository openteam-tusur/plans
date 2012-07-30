# encoding: utf-8

require 'spec_helper'

describe PurposesAndTasksPage do
  let(:work_programm) { Fabricate(:work_programm) }
  let(:page) { PurposesAndTasksPage.new work_programm }
  delegate :discipline, :to => :work_programm

  subject { page }

  describe '#dependencies' do
    subject { page.dependencies }

    it { should =~ /Дисциплина «Учебная дисциплина»/ }
    it { should =~ /цикл «ЕСН.Ф»/ }
    context 'направление обучения' do
      context 'ГОС есть' do
        before { page.speciality.should_receive(:gos).and_return(Gos.new(:title => 'Направление обучения ГОС')) }
        it { should =~ /по направлению «Направление обучения ГОС»/ }
      end
      context 'ГОСа нет' do
        it { should =~ /по направлению «--------------------»/ }
      end
    end

  end

  def mock_disciplines(kind, discipline_titles)
    disciplines = discipline_titles.map! {|discipline_title| Fabricate(:discipline, :title => discipline_title)}
    work_programm.should_receive(kind).any_number_of_times.and_return(disciplines)
  end

  describe '#previous_disciplines' do
    subject { page.previous_disciplines }
    context 'нет дисциплин' do
      before { mock_disciplines :previous_disciplines, [] }
      it { should be nil }
    end
    context 'одна дисциплина' do
      before { mock_disciplines :previous_disciplines, ['Дисциплина 1'] }
      it { should == 'Изучение дисциплины базируется на материалах курса «Дисциплина 1».' }
    end
    context 'две дисциплины' do
      before { mock_disciplines :previous_disciplines, ['Дисциплина 1', 'Дисциплина 2'] }
      it { should == 'Изучение дисциплины базируется на материалах таких курсов как «Дисциплина 1», «Дисциплина 2».' }
    end
  end

  describe '#current_disciplines' do
    subject { page.current_disciplines }
    context 'нет дисциплин' do
      before { mock_disciplines :current_disciplines, [] }
      it { should be nil }
    end
    context 'одна дисциплина' do
      before { mock_disciplines :current_disciplines, ['Дисциплина 1'] }
      it { should == 'При освоении данной дисциплины компетенции одновременно формируются с дисциплиной «Дисциплина 1».' }
    end
    context 'две дисциплины' do
      before { mock_disciplines :current_disciplines, ['Дисциплина 1', 'Дисциплина 2'] }
      it { should == 'При освоении данной дисциплины компетенции одновременно формируются с дисциплинами «Дисциплина 1», «Дисциплина 2».' }
    end
  end

  describe '#subsequent_disciplines' do
    subject { page.subsequent_disciplines }
    context 'нет дисциплин' do
      before { mock_disciplines :subsequent_disciplines, [] }
      it { should be nil }
    end
    context 'одна дисциплина' do
      before { mock_disciplines :subsequent_disciplines, ['Дисциплина 1'] }
      it { should == 'Она является основой для изучения дисциплины «Дисциплина 1».' }
    end
    context 'две дисциплины' do
      before { mock_disciplines :subsequent_disciplines, ['Дисциплина 1', 'Дисциплина 2'] }
      it { should == 'Она является основой для изучения следующих дисциплин: «Дисциплина 1», «Дисциплина 2».' }
    end
  end
end
