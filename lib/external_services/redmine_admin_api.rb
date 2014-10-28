class RedmineAdminApi

  STATUS_ACTIVE = 1
  STATUS_BLOCK = 3

  #RestClient::Unauthorized: 401 Unauthorized:
  #RestClient::InternalServerError: 500 Internal Server Error
  def initialize
    @token = Settings.redmine.token
    @url = Settings.redmine.base_url
    @auth_source_id = Settings.redmine.auth_source_id
  end

  def get_user_id_by_login(login)
    result_active = JSON.parse(RestClient.get("#{@url}/users.json", params: {key: @token, name: login}, content_type: :json, accept: :json))
    result_active['users'].each do |user|
      return user['id'] if user['login'] == login
    end
    result_block = JSON.parse(RestClient.get("#{@url}/users.json", params: {key: @token, name: login, status: STATUS_BLOCK}, content_type: :json, accept: :json))
    result_block['users'].each do |user|
      return user['id'] if user['login'] == login
    end
    nil
  end

  def exist?(login)
    if get_user_id_by_login(login)
      return true
    end
    false
  end

  def create_user(login, firstname, lastname, mail, clear_password)
    user_hash = {
        user: {
          login: login,
          firstname: firstname,
          lastname: lastname,
          mail: mail,
          password: clear_password,
          auth_source_id: @auth_source_id
        }
    }
    unless exist?(login)
      RestClient.post("#{@url}/users.json", user_hash.to_json, params: {key: @token}, content_type: :json, accept: :json)
    end
  end

  def block_user(login)
    user_id = get_user_id_by_login(login)
    user_hash = {
        user: {
            status: STATUS_BLOCK
        }
    }
    if user_id
      RestClient.put("#{@url}/users/#{user_id}.json", user_hash.to_json, params: {key: @token}, content_type: :json, accept: :json)
    end
  end

  def active_user(login)
    user_id = get_user_id_by_login(login)
    user_hash = {
        user: {
            status: STATUS_ACTIVE
        }
    }
    if user_id
      RestClient.put("#{@url}/users/#{user_id}.json", user_hash.to_json, params: {key: @token}, content_type: :json, accept: :json)
    end
  end


end