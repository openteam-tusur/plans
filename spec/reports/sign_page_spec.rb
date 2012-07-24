# encoding: utf-8

require 'spec_helper'

describe SignPage do
  let(:work_programm) { Fabricate(:work_programm) }
  let(:page) { SignPage.new(work_programm) }

  subject { page }

  describe '#authors_header' do
    subject { page.authors_header }
    let(:authors) { WorkProgramm.new.authors }

    context '1 автор' do
      before { work_programm.should_receive(:authors).and_return(authors.tap(&:shift)) }
      it { should == "Разработчик" }
    end

    context '2 автор' do
      before { work_programm.should_receive(:authors).and_return(authors) }
      it { should == "Разработчики" }
    end
  end

  describe '#authors' do
    describe '#first'  do
      subject { page.authors.first }
      it { should == ["Доцент каф. АОИ\nканд. экон. наук", "______________", "Сидоров А.А."]}
    end
  end
end
