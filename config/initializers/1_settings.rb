class Settings < Settingslogic
  source "#{Rails.root}/config/ldap-control-settings.yml"
  namespace Rails.env
  load!
end
