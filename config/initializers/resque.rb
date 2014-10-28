Resque.redis = Redis.new(:url => "redis://#{Settings.redis.host}:#{Settings.redis.port}/#{Settings.redis.database}")
Resque.redis.namespace = "ldapcontrol:resque"

class CanAccessResque
  def self.matches?(request)
    if request.session[:person] and Ldap::Person.find(request.session[:person])
      current_user = Ldap::Person.find(request.session[:person])
      Ability.new(current_user).can? :manage, Ldap::Person.new
    else
      false
    end
  end
end