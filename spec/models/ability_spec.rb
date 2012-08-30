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

  context 'менеджер кафедры' do
    subject { ability_for(manager_of(child_1)) }

    context 'управление направлениями подготовки' do
      let(:subdepartment_1) { Fabricate(:subdepartment, :context => child_1) }
      let(:subdepartment_2) { Fabricate(:subdepartment, :context => child_2) }
      let(:subspeciality_1) { Fabricate(:subspeciality, :subdepartment => subdepartment_1) }
      let(:subspeciality_2) { Fabricate(:subspeciality, :subdepartment => subdepartment_2) }
      let(:discipline_with_subdepartment_1) { Fabricate(:discipline, :subdepartment => subdepartment_1) }
      let(:discipline_with_subspeciality_1) { Fabricate(:discipline, :subspeciality => subspeciality_1) }
      let(:discipline) { Fabricate(:discipline) }

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
  end
end
