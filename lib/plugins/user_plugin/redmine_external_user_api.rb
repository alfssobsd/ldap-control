class UserPlugin::RedmineExternalUserApi < UserPlugin::BaseExternalUserApi

  STATUS_ACTIVE = 1
  STATUS_BLOCK = 3

  #RestClient::Unauthorized: 401 Unauthorized:
  #RestClient::InternalServerError: 500 Internal Server Error
  def initialize(logger)
    @logger = logger
    @token = Settings.redmine.token
    @url = Settings.redmine.base_url
    @auth_source_id = Settings.redmine.auth_source_id
  end

  def exist?(user)
    return true if get_user_id(user)
    false
  end

  def create(user, first_name, last_name, mail, password)
    user_hash = {
        user: {
          login: user,
          firstname: first_name,
          lastname: last_name,
          mail: mail,
          password: password,
          auth_source_id: @auth_source_id
        }
    }
    unless exist?(user)
      RestClient.post("#{@url}/users.json", user_hash.to_json, params: {key: @token}, content_type: :json, accept: :json)
    end
  end

  def update(user, first_name, last_name, mail)
    user_id = get_user_id(user)
    user_hash = {
        user: {
            firstname: first_name,
            lastname: last_name,
            mail: mail,
            auth_source_id: @auth_source_id
        }
    }
    if user_id
      RestClient.put("#{@url}/users/#{user_id}.json", user_hash.to_json, params: {key: @token}, content_type: :json, accept: :json)
    end
  end

  def is_actived?(user)
    return false if get_blocked_user(user)
    true
  end

  def deactivate(user)
    user_id = get_user_id(user)
    user_hash = {
        user: {
            status: STATUS_BLOCK
        }
    }
    if user_id
      RestClient.put("#{@url}/users/#{user_id}.json", user_hash.to_json, params: {key: @token}, content_type: :json, accept: :json)
    end
  end

  def activate(user)
    user_id = get_user_id(user)
    user_hash = {
        user: {
            status: STATUS_ACTIVE
        }
    }
    if user_id
      RestClient.put("#{@url}/users/#{user_id}.json", user_hash.to_json, params: {key: @token}, content_type: :json, accept: :json)
    end
  end


  protected

  def get_user_id(user)
    user_id = get_activated_user(user)
    user_id = get_blocked_user(user) unless user_id
    user_id
  end

  def get_blocked_user(user)
    result = JSON.parse(RestClient.get("#{@url}/users.json", params: {key: @token, name: user, status: STATUS_BLOCK}, content_type: :json, accept: :json))
    result['users'].each do |redmine_user|
      return redmine_user['id'] if redmine_user['login'] == user
    end
    nil
  end

  def get_activated_user(user)
    result = JSON.parse(RestClient.get("#{@url}/users.json", params: {key: @token, name: user}, content_type: :json, accept: :json))
    result['users'].each do |redmine_user|
      return redmine_user['id'] if redmine_user['login'] == user
    end
    nil
  end


end