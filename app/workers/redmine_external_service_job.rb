class RedmineExternalServiceJob < BaseExternalServiceJob
  @queue = :external_services
  @group_name = Settings.redmine.group
  @service_class = UserPlugin::RedmineExternalUserApi
end