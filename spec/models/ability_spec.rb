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

  let(:provided_context)        { root.children.create! }
  let(:graduated_context)       { root.children.create! }
  let(:profiled_context)        { root.children.create! }
  let(:provided_subdepartment)  { Fabricate(:subdepartment, :context => provided_context) }
  let(:profiled_subdepartment)  { Fabricate(:subdepartment, :context => profiled_context) }
  let(:graduated_subdepartment) { Fabricate(:subdepartment, :context => graduated_context) }
  let(:subspeciality)           { Fabricate(:subspeciality, :subdepartment => profiled_subdepartment, :graduated_subdepartment => graduated_subdepartment) }
  let(:another_subspeciality)   { Fabricate(:subspeciality) }
  let(:discipline)              { Fabricate(:discipline, :subdepartment => provided_subdepartment, :subspeciality => subspeciality) }
  let(:another_discipline)      { Fabricate(:discipline) }

  let(:work_programm)                   { Fabricate(:work_programm, :discipline => discipline, :creator_id => lecturer_of(discipline)) }
  let(:draft)                           { work_programm }
  let(:redux)                           { work_programm.tap{|p| p.state = 'redux'} }
  let(:check_by_provided_subdivision)   { work_programm.tap{|p| p.state = 'check_by_provided_subdivision'} }
  let(:check_by_profiled_subdivision)   { work_programm.tap{|p| p.state = 'check_by_profiled_subdivision'} }
  let(:check_by_graduated_subdivision)  { work_programm.tap{|p| p.state = 'check_by_graduated_subdivision'} }
  let(:check_by_library)                { work_programm.tap{|p| p.state = 'check_by_library'} }
  let(:check_by_methodological_office)  { work_programm.tap{|p| p.state = 'check_by_methodological_office'} }
  let(:check_by_educational_office)     { work_programm.tap{|p| p.state = 'check_by_educational_office'} }
  let(:released)                        { work_programm.tap{|p| p.state = 'released'} }

  subject { ability_for(user) }

  context 'автор' do
    let(:user) { lecturer_of(discipline) }
    context 'управление состоянием рабочей программы' do
      it { should     be_able_to(:create,           discipline.work_programms.new) }
      it { should_not be_able_to(:create,           another_discipline.work_programms.new) }
      it { should     be_able_to(:read,             another_discipline.work_programms.new) }
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
      context 'управление составными частями рабочей программы' do
        WorkProgramm::PART_CLASSES.each do |part_class|
          let(:object) { part_class.new }
          it "может управлять #{part_class.model_name.human}" do
            object.work_programm = work_programm
            should be_able_to(:manage, object)
          end
        end
      end
    end
  end

  context 'менеджер кафедры' do
    let(:user) { manager_of(provided_context) }

    context 'управление ООП' do
      let(:user) { manager_of(profiled_context) }
      it { should     be_able_to(:manage, subspeciality.build_programm) }
      it { should_not be_able_to(:manage, another_subspeciality.build_programm) }
    end

    context 'управление состоянием рабочей программы' do
      it { should     be_able_to(:create,           discipline.work_programms.new) }
      it { should_not be_able_to(:create,           another_discipline.work_programms.new) }
      it { should     be_able_to(:read,             another_discipline.work_programms.new) }
      it { should_not be_able_to(:shift_up,         draft) }
      it { should_not be_able_to(:shift_up,         redux) }
      it { should     be_able_to(:shift_up,         check_by_provided_subdivision) }
      it { should     be_able_to(:return_to_author, check_by_provided_subdivision) }
      it { should_not be_able_to(:shift_up,         check_by_profiled_subdivision) }
      it { should_not be_able_to(:return_to_author, check_by_profiled_subdivision) }
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

  context 'менеджер профилирующей кафедры' do
    let(:user) { manager_of(profiled_context) }
    it { should_not be_able_to(:shift_up,         draft) }
    it { should_not be_able_to(:shift_up,         redux) }
    it { should_not be_able_to(:shift_up,         check_by_provided_subdivision) }
    it { should_not be_able_to(:return_to_author, check_by_provided_subdivision) }
    it { should     be_able_to(:shift_up,         check_by_profiled_subdivision) }
    it { should     be_able_to(:return_to_author, check_by_profiled_subdivision) }
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

  context 'менеджер выпускающей кафедры' do
    let(:user) { manager_of(graduated_context) }
    it { should_not be_able_to(:shift_up,         draft) }
    it { should_not be_able_to(:shift_up,         redux) }
    it { should_not be_able_to(:shift_up,         check_by_provided_subdivision) }
    it { should_not be_able_to(:return_to_author, check_by_provided_subdivision) }
    it { should_not be_able_to(:shift_up,         check_by_profiled_subdivision) }
    it { should_not be_able_to(:return_to_author, check_by_profiled_subdivision) }
    it { should     be_able_to(:shift_up,         check_by_graduated_subdivision) }
    it { should     be_able_to(:return_to_author, check_by_graduated_subdivision) }
    it { should_not be_able_to(:shift_up,         check_by_library) }
    it { should_not be_able_to(:return_to_author, check_by_library) }
    it { should_not be_able_to(:shift_up,         check_by_methodological_office) }
    it { should_not be_able_to(:return_to_author, check_by_methodological_office) }
    it { should_not be_able_to(:shift_up,         check_by_educational_office) }
    it { should_not be_able_to(:return_to_author, check_by_educational_office) }
    it { should_not be_able_to(:shift_up,         released) }
    it { should_not be_able_to(:return_to_author, released) }
  end

  context 'сотрудник библиотеки' do
    let(:user) { librarian_of(root) }
    it { should_not be_able_to(:shift_up,         draft) }
    it { should_not be_able_to(:shift_up,         redux) }
    it { should_not be_able_to(:shift_up,         check_by_provided_subdivision) }
    it { should_not be_able_to(:return_to_author, check_by_provided_subdivision) }
    it { should_not be_able_to(:shift_up,         check_by_graduated_subdivision) }
    it { should_not be_able_to(:return_to_author, check_by_graduated_subdivision) }
    it { should     be_able_to(:shift_up,         check_by_library) }
    it { should     be_able_to(:return_to_author, check_by_library) }
    it { should_not be_able_to(:shift_up,         check_by_methodological_office) }
    it { should_not be_able_to(:return_to_author, check_by_methodological_office) }
    it { should_not be_able_to(:shift_up,         check_by_educational_office) }
    it { should_not be_able_to(:return_to_author, check_by_educational_office) }
    it { should_not be_able_to(:shift_up,         released) }
    it { should_not be_able_to(:return_to_author, released) }
  end

  context 'сотрудник учебного управления' do
    let(:user) { educationalist_of(root) }
    it { should_not be_able_to(:shift_up,         draft) }
    it { should_not be_able_to(:shift_up,         redux) }
    it { should_not be_able_to(:shift_up,         check_by_provided_subdivision) }
    it { should_not be_able_to(:return_to_author, check_by_provided_subdivision) }
    it { should_not be_able_to(:shift_up,         check_by_graduated_subdivision) }
    it { should_not be_able_to(:return_to_author, check_by_graduated_subdivision) }
    it { should_not be_able_to(:shift_up,         check_by_library) }
    it { should_not be_able_to(:return_to_author, check_by_library) }
    it { should_not be_able_to(:shift_up,         check_by_methodological_office) }
    it { should_not be_able_to(:return_to_author, check_by_methodological_office) }
    it { should     be_able_to(:shift_up,         check_by_educational_office) }
    it { should     be_able_to(:return_to_author, check_by_educational_office) }
    it { should     be_able_to(:shift_up,         released) }
    it { should     be_able_to(:return_to_author, released) }
  end
end
