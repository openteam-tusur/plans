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

  describe '#previous_disciplines' do
    subject { page.previous_disciplines }
    context 'нет дисциплин' do
      it { should be nil }
    end
    context 'есть дисциплины' do
      before { work_programm.previous_disciplines.create(:title => 'Дисциплина 1').save(:validate => false) }
      context 'одна' do
        it { should == 'Изучение дисциплины базируется на материалах курса «Дисциплина 1».' }
      end
      context 'две' do
        before { work_programm.previous_disciplines.create(:title => 'Дисциплина 2').save(:validate => false) }
        it { should == 'Изучение дисциплины базируется на материалах таких курсов как «Дисциплина 1», «Дисциплина 2».' }
      end
    end
  end

  describe '#current_disciplines' do
    subject { page.current_disciplines }
    context 'нет дисциплин' do
      it { should be nil }
    end
    context 'есть дисциплины' do
      before { work_programm.current_disciplines.create(:title => 'Дисциплина 1').save(:validate => false) }
      before { work_programm.current_disciplines.create(:title => 'Дисциплина 2').save(:validate => false) }
      it { should == 'При освоении данной дисциплины компетенции одновременно формируются с дисциплинами «Дисциплина 1», «Дисциплина 2».' }
    end
  end

  describe '#subsequent_disciplines' do
    subject { page.subsequent_disciplines }
    context 'нет дисциплин' do
      it { should be nil }
    end
    context 'есть дисциплины' do
      before { work_programm.subsequent_disciplines.create(:title => 'Дисциплина 1').save(:validate => false) }
      before { work_programm.subsequent_disciplines.create(:title => 'Дисциплина 2').save(:validate => false) }
      it { should == 'Она является основой для изучения следующих дисциплин: «Дисциплина 1», «Дисциплина 2».' }
    end
  end
end
