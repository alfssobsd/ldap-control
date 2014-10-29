Resque.redis = Redis.new(:url => "redis://#{Settings.redis.host}:#{Settings.redis.port}/#{Settings.redis.database}")
Resque.redis.namespace = "ldapcontrol:resque"

class CanAccessResque
  def self.matches?(request)
    current_user = request.env['warden'].user
    return false if current_user.blank?
    Ability.new(current_user).can? :manage, Ldap::Person.new
  end
end