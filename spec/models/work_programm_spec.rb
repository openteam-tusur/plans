# encoding: utf-8

require 'spec_helper'

describe WorkProgramm do
  let(:work_programm) { Fabricate(:work_programm) }
  delegate :discipline, :to => :work_programm

  subject { work_programm }

  describe '#dependencies_html' do
    subject { work_programm.dependencies_html }

    it { should =~ /Дисциплина «Учебная дисципина»/ }
    it { should =~ /цикла «ФТД. Факультативы»/ }
    it { should =~ /по направлению «Направление обучения»/ }

    context 'федеральный компонент' do
      it { should =~ /входит в федеральный компонент/ }
    end

    context 'региональный компонет' do
      before { discipline.component = 'Р1' }
      it { should =~ /входит в региональный компонент/ }
    end

    context 'выборный компонет' do
      before { discipline.component = 'В1' }
      it { should =~ /входит в выборный компонент/ }
    end

    context 'неизвестный компонет' do
      before { discipline.component = 'Г1' }
      specify { expect{ work_programm.dependencies_html }.should raise_error }
    end
  end

  describe '#previous_disciplines_html' do
    subject { work_programm.previous_disciplines_html }
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

  describe '#current_disciplines_html' do
    subject { work_programm.current_disciplines_html }
    context 'нет дисциплин' do
      it { should be nil }
    end
    context 'есть дисциплины' do
      before { work_programm.current_disciplines.create(:title => 'Дисциплина 1').save(:validate => false) }
      before { work_programm.current_disciplines.create(:title => 'Дисциплина 2').save(:validate => false) }
      it { should == 'При освоении данной дисциплины компетенции одновременно формируются с дисциплинами «Дисциплина 1», «Дисциплина 2».' }
    end
  end

  describe '#subsequent_disciplines_html' do
    subject { work_programm.subsequent_disciplines_html }
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
