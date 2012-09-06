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
    it { should =~ /по направлению «Специальность подготовки»/ }
  end

  def mock_disciplines(kind, disciplines_count)
    disciplines = []
    (1..disciplines_count).each do |discipline_number|
      disciplines << Fabricate(:discipline, :title => "Дисциплина #{discipline_number}", :cycle_code => "ЕСН.Ф")
    end
    work_programm.should_receive(kind).any_number_of_times.and_return(disciplines)
  end

  describe '#previous_disciplines' do
    subject { page.previous_disciplines }
    context 'нет дисциплин' do
      before { mock_disciplines :previous_disciplines, 0 }
      it { should == '' }
    end
    context 'одна дисциплина' do
      before { mock_disciplines :previous_disciplines, 1 }
      it { should == 'Изучение дисциплины базируется на материалах курса «Дисциплина 1» (ЕСН.Ф).' }
    end
    context 'две дисциплины' do
      before { mock_disciplines :previous_disciplines, 2 }
      it { should == 'Изучение дисциплины базируется на материалах таких курсов как «Дисциплина 1» (ЕСН.Ф), «Дисциплина 2» (ЕСН.Ф).' }
    end
  end

  describe '#current_disciplines' do
    subject { page.current_disciplines }
    context 'нет дисциплин' do
      before { mock_disciplines :current_disciplines, 0 }
      it { should == '' }
    end
    context 'одна дисциплина' do
      before { mock_disciplines :current_disciplines, 1 }
      it { should == 'При освоении данной дисциплины компетенции одновременно формируются с дисциплиной «Дисциплина 1» (ЕСН.Ф).' }
    end
    context 'две дисциплины' do
      before { mock_disciplines :current_disciplines, 2 }
      it { should == 'При освоении данной дисциплины компетенции одновременно формируются с дисциплинами «Дисциплина 1» (ЕСН.Ф), «Дисциплина 2» (ЕСН.Ф).' }
    end
  end

  describe '#subsequent_disciplines' do
    subject { page.subsequent_disciplines }
    context 'нет дисциплин' do
      before { mock_disciplines :subsequent_disciplines, 0 }
      it { should == '' }
    end
    context 'одна дисциплина' do
      before { mock_disciplines :subsequent_disciplines, 1 }
      it { should == 'Она является основой для изучения дисциплины «Дисциплина 1» (ЕСН.Ф).' }
    end
    context 'две дисциплины' do
      before { mock_disciplines :subsequent_disciplines, 2 }
      it { should == 'Она является основой для изучения следующих дисциплин: «Дисциплина 1» (ЕСН.Ф), «Дисциплина 2» (ЕСН.Ф).' }
    end
  end
end
