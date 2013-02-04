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
      user.permissions.any?
    end

    can :manage, :permissions do
      user.manager?
    end

    can :manage, :audits do
      user.manager_of? Context.first
    end

    ## app specific

    can :manage, :all if user.manager_of? Context.first

    can :manage, Permission do |permission|
      if permission.context.is_a?(Discipline)
        permission.context.is_a?(Discipline) &&
          (
            can?(:manage, permission.context.provided_subdepartment) ||
            can?(:manage, permission.context.profiled_subdepartment) ||
            can?(:manage, permission.context.graduated_subdepartment)
          )
      end
    end

    can :manage, Subdepartment do |subdepartment|
      can? :manage, subdepartment.context
    end

    can :manage, Discipline do |discipline|
      can? :manage, discipline.provided_subdepartment
    end

    can :manage, Discipline do |discipline|
      can? :manage, discipline.profiled_subdepartment
    end

    can :manage, Discipline do |discipline|
      can? :manage, discipline.graduated_subdepartment
    end

    can :manage, Discipline do |discipline|
      user.lecturer_of? discipline
    end

    can :manage, Programm do |programm|
      can? :manage, programm.with_programm.profiled_subdepartment
    end

    alias_action :update, :destroy, :edit_purpose, :get_purpose, :get_related_disciplines, :to => :modify

    can :create, WorkProgramm do |work_programm|
      can?(:manage, work_programm.discipline)
    end

    can :upload_file, WorkProgramm do |work_programm|
      can? :manage, work_programm.provided_subdepartment
    end

    can :upload_file, WorkProgramm do |work_programm|
      can? :manage, work_programm.profiled_subdepartment
    end

    can :upload_file, WorkProgramm do |work_programm|
      can? :manage, work_programm.graduated_subdepartment
    end

    can :modify, WorkProgramm do |work_programm|
      work_programm.file_url? && can?(:upload_file, work_programm)
    end

    can :modify, WorkProgramm do |work_programm|
      work_programm.draft_or_redux? && work_programm.creator == user
    end

    can :get_event_actions, WorkProgramm

    can [:shift_up, :return_to_author], WorkProgramm do |work_programm|
      case work_programm.state.to_sym
      when :draft, :redux
        can? :modify, work_programm
      when :check_by_provided_subdepartment
        can? :manage, work_programm.provided_subdepartment
      when :check_by_profiled_subdepartment
        can? :manage, work_programm.profiled_subdepartment
      when :check_by_graduated_subdepartment
        can? :manage, work_programm.graduated_subdepartment
      when :check_by_library
        user.librarian?
      when :check_by_methodological_office
        user.methodologist?
      when :check_by_educational_office, :released
        user.educationalist?
      end
    end

    can :manage, Protocol do |protocol|
      can?(:manage, protocol.work_programm.provided_subdepartment) && protocol.work_programm.check_by_provided_subdepartment?
    end

    can :manage, WorkProgramm::PART_CLASSES do |part|
      can? :modify, part.work_programm
    end

    can :read, [Speciality, Subspeciality, Discipline, WorkProgramm, Message]
  end
end
