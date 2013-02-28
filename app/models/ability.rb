class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    ## common
    can :manage, :all if user.manager?

    can :manage, :application do
      user.permissions.any?
    end
  end
end
