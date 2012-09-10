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

    can :create, WorkProgramm do |work_programm|
      can?(:manage, work_programm.discipline)
    end

    alias_action :update, :delete, :to => :modify

    can :modify, WorkProgramm do |work_programm|
      work_programm.draft_or_redux? && work_programm.creator == user
    end

    can [:shift_up, :return_to_author], WorkProgramm do |work_programm|
      case work_programm.state.to_sym
      when :draft, :redux
        can? :modify, work_programm
      when :check_by_provided_subdivision
        can? :manage, work_programm.discipline.subdepartment
      when :check_by_graduated_subdivision
        can? :manage, work_programm.discipline.subspeciality.subdepartment
      when :check_by_library
        user.librarian?
      when :check_by_methodological_office
        user.methodologist?
      when :check_by_educational_office, :released
        user.educationalist?
      end
    end

    can :manage, Protocol do |protocol|
      can?(:modify, protocol.work_programm.discipline.subdepartment) && protocol.work_programm.check_by_provided_subdivision?
    end

    can :manage, WorkProgramm::PART_CLASSES do |part|
      can? :modify, part.work_programm
    end

    can :read, [Speciality, Subspeciality, Discipline, WorkProgramm, Message]
  end
end
