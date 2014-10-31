class UserPlugin::YandexExternalUserApi < UserPlugin::BaseExternalUserApi
  URL_API = 'https://pddimp.yandex.ru'

  def initialize(logger)
    @logger = logger
    @token = Settings.yandex.yandex_mail_admin.token
    @domains = Settings.yandex.yandex_mail_admin.domains
  end

  def exist?(user)
    xml = Nokogiri::XML(RestClient.get "#{URL_API}/check_user.xml", params: {token: @token, login: user})
    return true if xml.xpath('//result').text == "exists"
    false
  end

  def set_password(user, password)
    xml = Nokogiri::XML(RestClient.get "#{URL_API}/edit_user.xml", params: {token: @token, login: user, password: password})
    return true unless xml.xpath('//ok').empty?
    false
  end

  def create(user, first_name, last_name, mail, password)
    login, domain = user.split('@')
    xml = Nokogiri::XML(RestClient.get "#{URL_API}/api/reg_user.xml", params: {token: @token, login: login, domain: domain, passwd: password})

    # @logger.debug(xml.xpath('//success'))

    unless xml.xpath('//success').empty?
      update_user_info(user, first_name, last_name)
    end
  end

  def update(user, first_name, last_name, mail)
    update_user_info(user, first_name, last_name)
  end

  def deactivate(user)
    set_password(user, SecureRandom.base64)
  end


  protected

  def update_user_info(user, first_name, last_name)
    xml = Nokogiri::XML(RestClient.get "#{URL_API}/edit_user.xml", params: {token: @token, login: user, iname: first_name, fname: last_name})
    return true unless xml.xpath('//ok').empty?
    false
  end
end