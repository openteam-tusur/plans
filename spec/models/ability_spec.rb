# encoding: utf-8

require 'spec_helper'

describe Ability do
  context 'менеджер' do
    context 'корневого контекста' do
      subject { ability_for(manager_of(root)) }

      context 'управление контекстами' do
        it { should     be_able_to(:manage, root) }
        it { should     be_able_to(:manage, child_1) }
        it { should     be_able_to(:manage, child_1_1) }
        it { should     be_able_to(:manage, child_2) }
      end

      context 'управление правами доступа' do
        it { should     be_able_to(:manage, another_manager_of(root).permissions.first) }
        it { should     be_able_to(:manage, another_manager_of(child_1).permissions.first) }
        it { should     be_able_to(:manage, another_manager_of(child_1_1).permissions.first) }
        it { should     be_able_to(:manage, another_manager_of(child_2).permissions.first) }
      end
    end

    context 'вложенного контекста' do
      subject { ability_for(manager_of(child_1)) }

      context 'управление контекстами' do
        it { should_not be_able_to(:manage, root) }
        it { should     be_able_to(:manage, child_1) }
        it { should     be_able_to(:manage, child_1_1) }
        it { should_not be_able_to(:manage, child_2) }
      end

      context 'управление правами доступа' do
        it { should_not be_able_to(:manage, another_manager_of(root).permissions.first) }
        it { should     be_able_to(:manage, another_manager_of(child_1).permissions.first) }
        it { should     be_able_to(:manage, another_manager_of(child_1_1).permissions.first) }
        it { should_not be_able_to(:manage, another_manager_of(child_2).permissions.first) }
      end
    end
  end

  let(:subdepartment_1) { Fabricate(:subdepartment, :context => child_1) }
  let(:subdepartment_2) { Fabricate(:subdepartment, :context => child_2) }
  let(:subspeciality_1) { Fabricate(:subspeciality, :subdepartment => subdepartment_1) }
  let(:subspeciality_2) { Fabricate(:subspeciality, :subdepartment => subdepartment_2) }
  let(:discipline_with_subdepartment_1) { Fabricate(:discipline, :subdepartment => subdepartment_1) }
  let(:discipline_with_subspeciality_1) { Fabricate(:discipline, :subspeciality => subspeciality_1) }
  let(:discipline) { Fabricate(:discipline) }

  let(:work_programm) { Fabricate(:work_programm, :discipline => discipline_with_subdepartment_1, :creator_id => user) }
  let(:draft)                           { work_programm }
  let(:redux)                           { work_programm.tap{|p| p.state = 'redux'} }
  let(:check_by_provided_subdivision)   { work_programm.tap{|p| p.state = 'check_by_provided_subdivision'} }
  let(:check_by_graduated_subdivision)  { work_programm.tap{|p| p.state = 'check_by_graduated_subdivision'} }
  let(:check_by_library)                { work_programm.tap{|p| p.state = 'check_by_library'} }
  let(:check_by_methodological_office)  { work_programm.tap{|p| p.state = 'check_by_methodological_office'} }
  let(:check_by_educational_office)     { work_programm.tap{|p| p.state = 'check_by_educational_office'} }
  let(:released)                        { work_programm.tap{|p| p.state = 'released'} }

  context 'менеджер кафедры' do
    subject { ability_for(manager_of(child_1)) }

    context 'управление направлениями подготовки' do

      context 'управление ООП' do
        it { should be_able_to(:manage, subspeciality_1.build_programm) }
        it { should_not be_able_to(:manage, subspeciality_2.build_programm) }
      end

      context 'управление рабочими программами' do
        it { should be_able_to(:manage, discipline_with_subdepartment_1.work_programms.new) }
        it { should be_able_to(:manage, discipline_with_subspeciality_1.work_programms.new) }
        it { should_not be_able_to(:manage, discipline.work_programms.new) }
        it { should be_able_to(:read, discipline.work_programms.new) }
      end

      context 'управление составными частями рабочей программы' do
        WorkProgramm::PART_CLASSES.each do |part_class|
          let(:object) { part_class.new }
          it "может управлять #{part_class.model_name.human}" do
            object.work_programm = discipline_with_subdepartment_1.work_programms.new
            should be_able_to(:manage, object)
          end
          it "не может управлять #{part_class.model_name.human}" do
            object.work_programm = discipline.work_programms.new
            should_not be_able_to(:manage, object)
          end
        end
      end
    end
    context 'управление состоянием рабочей программы' do
      it { should_not be_able_to(:shift_up,         draft) }
      it { should_not be_able_to(:shift_up,         redux) }
      it { should     be_able_to(:shift_up,         check_by_provided_subdivision) }
      it { should     be_able_to(:return_to_author, check_by_provided_subdivision) }
      it { should_not be_able_to(:shift_up,         check_by_graduated_subdivision) }
      it { should_not be_able_to(:return_to_author, check_by_graduated_subdivision) }
      it { should_not be_able_to(:shift_up,         check_by_library) }
      it { should_not be_able_to(:return_to_author, check_by_library) }
      it { should_not be_able_to(:shift_up,         check_by_methodological_office) }
      it { should_not be_able_to(:return_to_author, check_by_methodological_office) }
      it { should_not be_able_to(:shift_up,         check_by_educational_office) }
      it { should_not be_able_to(:return_to_author, check_by_educational_office) }
      it { should_not be_able_to(:shift_up,         released) }
      it { should_not be_able_to(:return_to_author, released) }
    end
  end


  context 'автор' do
    let(:user) { lecturer_of(discipline_with_subdepartment_1) }
    subject { ability_for(user) }
    context 'управление состоянием рабочей программы' do
      it { should     be_able_to(:shift_up,         draft) }
      it { should     be_able_to(:shift_up,         redux) }
      it { should_not be_able_to(:shift_up,         check_by_provided_subdivision) }
      it { should_not be_able_to(:return_to_author, check_by_provided_subdivision) }
      it { should_not be_able_to(:shift_up,         check_by_graduated_subdivision) }
      it { should_not be_able_to(:return_to_author, check_by_graduated_subdivision) }
      it { should_not be_able_to(:shift_up,         check_by_library) }
      it { should_not be_able_to(:return_to_author, check_by_library) }
      it { should_not be_able_to(:shift_up,         check_by_methodological_office) }
      it { should_not be_able_to(:return_to_author, check_by_methodological_office) }
      it { should_not be_able_to(:shift_up,         check_by_educational_office) }
      it { should_not be_able_to(:return_to_author, check_by_educational_office) }
      it { should_not be_able_to(:shift_up,         released) }
      it { should_not be_able_to(:return_to_author, released) }
    end
  end
end
