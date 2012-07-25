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
      its(:post) { should == 'Доцент каф. АОИ' }
      its(:science_post) { should == 'канд. экон. наук' }
      its(:short_name) { should == 'Сидоров А.А.' }
    end
  end

  describe '#gos' do
    subject { page.gos }
    context 'founded' do
      before { Gos.create! :speciality_code => page.speciality.code, :code => '000', :title => 'ГОС', :approved_on => '01.01.2012'}
      its([:title]) { should == '000 «ГОС»' }
      its([:approved_on]) { should == '01.01.2012 г.' }
    end
    context 'not founded' do
      its([:title]) { should == '--------------------' }
      its([:approved_on]) { should == '----------' }
    end
  end

  its('subdepartment_chief.post') { should == 'Зав. обеспечивающей кафедрой КО' }
  its('department_chief.post') { should == 'Декан ФО' }

  describe '#coordiantors' do
    subject { page.coordiantors }

    context 'выпускающая и профилирующая кафедра одинаковая' do
      before { page.subspeciality.graduate_subdepartment = page.subspeciality.subdepartment }
      it { should have(1).item }
      its('first.post') { should == 'Зав. профилирующей и выпускающей кафедрой КО' }
    end

    context 'выпускающая и профилирующая кафедры одинаковые' do
      before { page.subspeciality.graduate_subdepartment = Fabricate(:subdepartment, :abbr => 'ЕОК') }
      it { should have(2).item }
      its('first.post') { should == 'Зав. профилирующей кафедрой КО' }
      its('second.post') { should == 'Зав. выпускающей кафедрой ЕОК' }
    end
  end
end
