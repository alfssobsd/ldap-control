class YandexExternalServiceJob < BaseExternalServiceJob
  @queue = :external_services
  @group_name = Settings.yandex.yandex_mail_admin.group
  @domains = Settings.yandex.yandex_mail_admin.domains
  @service_class = UserPlugin::YandexExternalUserApi
end