# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :redis_session_store, {
    key: '_LdapControl_session',
    redis: {
        host: Settings.redis.host,
        port: Settings.redis.port,
        db: Settings.redis.database,
        key_prefix: 'ldapcontrol:session:',
        expire_after: 30.days
    }
}
