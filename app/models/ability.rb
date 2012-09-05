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

    can :manage, Permission do |permission|
      if permission.context.is_a?(Discipline)
        permission.context.is_a?(Discipline) &&
          (can?(:manage, permission.context.subdepartment) ||
           can?(:manage, permission.context.subspeciality.subdepartment))
      end
    end

    can :manage, Subdepartment do |subdepartment|
      can? :manage, subdepartment.context
    end

    can :manage, Discipline do |discipline|
      can? :manage, discipline.subdepartment
    end

    can :manage, Discipline do |discipline|
      can? :manage, discipline.subspeciality.subdepartment
    end

    can :manage, Discipline do |discipline|
      user.lecturer_of? discipline
    end

    can :manage, Programm do |programm|
      can? :manage, programm.with_programm.subdepartment
    end

    can :manage, WorkProgramm do |work_programm|
      can?(:manage, work_programm.discipline) && (work_programm.draft? || work_programm.redux?)
    end

    can [:shift_up, :return_to_author], WorkProgramm do |work_programm|
      can?(:manage, work_programm.discipline)
    end

    can :manage, Protocol do |protocol|
      can?(:manage, protocol.work_programm.discipline.subdepartment) && protocol.work_programm.check_by_provided_subdivision?
    end

    can :manage, WorkProgramm::PART_CLASSES do |part|
      can? :manage, part.work_programm
    end

    can :read, [Speciality, Subspeciality, Discipline, WorkProgramm, Message]
  end
end
