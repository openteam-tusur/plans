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
end
