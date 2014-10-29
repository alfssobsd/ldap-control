Rails.application.config.middleware.use Warden::Manager do |manager|
  manager.default_strategies :password
  manager.failure_app = lambda { |env| SessionsController.action(:new).call(env) }
end

Warden::Manager.serialize_into_session do |person|
  person.uid
end

Warden::Manager.serialize_from_session do |uid|
  Ldap::Person.find(uid)
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