class GmailAdminApi
  require 'google/api_client'

  #тут получать ключи и имя апы
  #https://console.developers.google.com

  #тут выставлять разрешение для ключей
  #https://admin.google.com/{domain.name}/AdminHome?chromeless=1#OGX:ManageOauthClients

  #список разрешений через запятую
  #https://www.googleapis.com/auth/admin.directory.group,https://www.googleapis.com/auth/admin.directory.group.readonly ,https://www.googleapis.com/auth/admin.directory.orgunit,https://www.googleapis.com/auth/admin.directory.orgunit.readonly,https://www.googleapis.com/auth/admin.directory.user,https://www.googleapis.com/auth/admin.directory.user.readonly
  def initialize
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

  def exist?(email)
    result = @client.execute(
        :api_method => @admin_api.users.get,
        :parameters => {userKey: email},
    )
    return true if result.status == 200
    false
  end

  def set_password(email, clear_password)
    result = @client.execute(
        :api_method => @admin_api.users.update,
        :parameters => {
            :userKey => email,
        },
        :body_object => {
            changePasswordAtNextLogin: false,
            hashFunction: 'SHA-1',
            password: Digest::SHA1.hexdigest(clear_password)
        }
    )
    return true if result.status == 200
    false
  end

  def set_admin_status(email, status)
    result = @client.execute(
        :api_method => @admin_api.users.make_admin,
        :parameters => {
            :userKey => email,
        },
        :body_object => {
            status: status,
        }
    )
    return true if result.status == 200
    false
  end

  def create_user(email, first_name, last_name, clear_password)
    result = @client.execute(
        :api_method => @admin_api.users.insert,
        :body_object => {
            primaryEmail: email,
            hashFunction: 'SHA-1',
            name: {
                familyName: last_name,
                givenName: first_name,
            },
            changePasswordAtNextLogin: false,
            password: Digest::SHA1.hexdigest(clear_password)
        }
    )
    return true if result.status == 201
    false
  end

  def block_user
    set_password(email, SecureRandom.base64)
  end

  def delete_user(email)
    result = @client.execute(
        :api_method => @admin_api.users.insert,
        :parameters => {
            :userKey => email,
        },
    )
    return true if result.status == 200
    false
  end
end