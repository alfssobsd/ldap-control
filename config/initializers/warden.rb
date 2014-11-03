Rails.application.config.middleware.use Warden::Manager do |manager|
  manager.failure_app = lambda { |env|
    failure_action = env["warden.options"][:action].to_sym
    SessionsController.action(failure_action).call(env)
  }
  manager.default_scope = :user
  manager.scope_defaults( :user, :strategies => [:password], :action => "new")
  manager.scope_defaults(
      :api_public,
      :strategies => [:api_public],
      :store        => false,
      :action       => "unauthenticated_api"
  )
end

Warden::Manager.serialize_into_session do |person|
  person.uid
end

Warden::Manager.serialize_from_session do |uid|
  Ldap::Person.find(uid)
end

Warden::Manager.after_set_user do |user, auth, opts|
  #TODO:проверить что пользователь активен
  # unless user.active?
  #   auth.logout
  #   throw(:warden, :message => "User not active")
  # end
end


Warden::Strategies.add(:password) do
  def valid?
    params['ldap_person'] && params['ldap_person']['uid'] && params['ldap_person']['password']
  end

  def authenticate!
    person = Ldap::Person.authenticate(params['ldap_person']['uid'], params['ldap_person']['password'])
    if person
      success! person
    else
      fail "Invalid login or password"
    end
  end
end

Warden::Strategies.add(:api_public) do
  def valid?
    params['api_token']
  end

  def authenticate!
    if Settings.api.public.keys.include?(params['api_token'])
      success! Ldap::Person.new
    else
      fail "Invalid api_token"
    end
  end
end