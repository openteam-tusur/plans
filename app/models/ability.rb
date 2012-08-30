class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    ## common
    can :manage, Context do |context|
      user.manager_of? context
    end

    can :manage, Permission do |permission|
      permission.context && user.manager_of?(permission.context)
    end

    can [:new, :create], Permission do |permission|
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

    can :manage, :all if user.manager_of? Context.first

    can :manage, Subdepartment do |subdepartment|
      can? :manage, subdepartment.context
    end

    can :manage, Permission do |permission|
      if permission.context.is_a?(Discipline)
        permission.context.is_a?(Discipline) &&
          (can?(:manage, permission.context.subdepartment) ||
           can?(:manage, permission.context.subspeciality.subdepartment))
      end
    end

    can :read, [Speciality, Subspeciality, Discipline, WorkProgramm]

    can :manage, Programm do |programm|
      user.manager_of? programm.with_programm.subdepartment.context
    end

    can :manage, WorkProgramm do |work_programm|
      user.manager_of? work_programm.discipline.subdepartment.context
    end

    can :manage, WorkProgramm do |work_programm|
      user.manager_of? work_programm.discipline.subspeciality.subdepartment.context
    end

    can :manage, WorkProgramm::PART_CLASSES do |part|
      can? :manage, part.work_programm
    end
  end
end
