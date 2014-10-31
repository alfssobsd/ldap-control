class GmailExternalServiceJob < BaseExternalServiceJob
  @queue = :external_services
  @group_name = Settings.google.gmail_admin.group
  @domains = Settings.google.gmail_admin.domains
  @service_class = UserPlugin::GmailExternalUserApi
end