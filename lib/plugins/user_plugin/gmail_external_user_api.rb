class UserPlugin::GmailExternalUserApi < UserPlugin::BaseExternalUserApi
  require 'google/api_client'
  #тут получать ключи и имя апы
  #https://console.developers.google.com

  #тут выставлять разрешение для ключей
  #https://admin.google.com/{domain.name}/AdminHome?chromeless=1#OGX:ManageOauthClients

  #список разрешений через запятую
  #https://www.googleapis.com/auth/admin.directory.group,https://www.googleapis.com/auth/admin.directory.group.readonly ,https://www.googleapis.com/auth/admin.directory.orgunit,https://www.googleapis.com/auth/admin.directory.orgunit.readonly,https://www.googleapis.com/auth/admin.directory.user_plugin,https://www.googleapis.com/auth/admin.directory.user_plugin.readonly
  def initialize(logger)
    @logger = logger
    @client = Google::APIClient.new({'application_name' => Settings.google.gmail_admin.app_name})
    @admin_api = @client.discovered_api('admin', 'directory_v1')
    key = Google::APIClient::KeyUtils.load_from_pkcs12(Settings.google.gmail_admin.key_path, 'notasecret')
    @client.authorization = Signet::OAuth2::Client.new(
        :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
        :audience => 'https://accounts.google.com/o/oauth2/token',
        :scope => [
            'https://www.googleapis.com/auth/admin.directory.group',
            'https://www.googleapis.com/auth/admin.directory.group.readonly',
            'https://www.googleapis.com/auth/admin.directory.orgunit',
            'https://www.googleapis.com/auth/admin.directory.orgunit.readonly',
            'https://www.googleapis.com/auth/admin.directory.user',
            'https://www.googleapis.com/auth/admin.directory.user.readonly',
        ],
        :issuer => Settings.google.gmail_admin.service_email,
        :signing_key => key,
        :person => Settings.google.gmail_admin.admin_email)
    @client.authorization.fetch_access_token!
  end

  def exist?(user)
    result = @client.execute(
        :api_method => @admin_api.users.get,
        :parameters => {userKey: user},
    )
    return true if result.status == 200
    false
  end

  def set_password(user, password)
    result = @client.execute(
        :api_method => @admin_api.users.update,
        :parameters => {
            :userKey => user,
        },
        :body_object => {
            changePasswordAtNextLogin: false,
            hashFunction: 'SHA-1',
            password: Digest::SHA1.hexdigest(password)
        }
    )
    return true if result.status == 200
    false
  end

  def create(user, first_name, last_name, mail, password)
    result = @client.execute(
        :api_method => @admin_api.users.insert,
        :body_object => {
            primaryEmail: user,
            hashFunction: 'SHA-1',
            name: {
                givenName: first_name,
                familyName: last_name,
            },
            changePasswordAtNextLogin: false,
            password: Digest::SHA1.hexdigest(password)
        }
    )
    return true if result.status == 201
    false
  end

  def update(user, first_name, last_name, mail)
    result = @client.execute(
        :api_method => @admin_api.users.update,
        :parameters => {
            :userKey => user,
        },
        :body_object => {
            name: {
                givenName: first_name,
                familyName: last_name,
            },
        }
    )
    return true if result.status == 200
    false
  end


  def is_actived?(user)
    result = @client.execute(
        :api_method => @admin_api.users.get,
        :parameters => {userKey: user},
    )
    if result.status == 200
      hash_result = JSON.parse(result.body)
      return true unless hash_result['suspended']
      false
    end
  end

  def activate(user)
    result = @client.execute(
        :api_method => @admin_api.users.update,
        :parameters => {
            :userKey => user,
        },
        :body_object => {
            suspended: false
        }
    )
    return true if result.status == 200
    false
  end

  def deactivate(user)
    result = @client.execute(
        :api_method => @admin_api.users.update,
        :parameters => {
            :userKey => user,
        },
        :body_object => {
            suspended: true
        }
    )
    return true if result.status == 200
    false
  end

end