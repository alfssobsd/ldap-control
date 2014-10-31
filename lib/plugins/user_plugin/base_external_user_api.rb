class UserPlugin::BaseExternalUserApi

  def exist?(user)

  end

  def set_password(user, password)

  end

  def is_actived?(user)
    true
  end

  def activate(user)
    true
  end

  def deactivate(user)
    true
  end

  def create(user, first_name, last_name, mail, password)

  end

  def update(user, first_name, last_name, mail)

  end
end