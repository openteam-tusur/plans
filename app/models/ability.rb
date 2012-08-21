class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    ## common
    can :manage, Context do | context |
      user.manager_of? context
    end

    can :manage, Permission do | permission |
      permission.context && user.manager_of?(permission.context)
    end

    can [:new, :create], Permission do | permission |
      !permission.context && user.manager?
    end

    can [:search, :index], User do
      user.manager?
    end

    can :manage, :application do
      user.have_permissions?
    end

    can :manage, :permissions do
      user.manager?
    end

    can :manage, :audits do
      user.manager_of? Context.first
    end

    ## specific

    can :manage, :all do
      user.manager_of? Context.first
    end

    ## methodologist
    can :read, [Speciality, Subspeciality, Discipline, WorkProgramm]

    can :manage, Programm do |programm|
      user.methodologist_of? programm.with_programm.subdepartment.context
    end

    can :manage, WorkProgramm do |work_programm|
      user.methodologist_of? work_programm.discipline.subdepartment.context
    end

    can :manage, WorkProgramm do |work_programm|
      user.methodologist_of? work_programm.discipline.subspeciality.subdepartment.context
    end

    can :manage, WorkProgramm::PART_CLASSES do |part|
      can? :manage, part.work_programm
    end
  end
end
