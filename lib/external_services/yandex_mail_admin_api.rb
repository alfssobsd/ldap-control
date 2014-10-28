class YandexMailAdminApi
  URL_API = 'https://pddimp.yandex.ru'

  def initialize
    @token = Settings.yandex.yandex_mail_admin.token
    @domains = Settings.yandex.yandex_mail_admin.domains
  end

  def exist?(email)
    xml = Nokogiri::XML(RestClient.get "#{URL_API}/check_user.xml", params: {token: @token, login: email})
    return true if xml.xpath('//result').text == "exists"
    false
  end

  def set_password(email, clear_password)
    xml = Nokogiri::XML(RestClient.get "#{URL_API}/edit_user.xml", params: {token: @token, login: email, password: clear_password})
    return true unless xml.xpath('//ok').empty?
    false
  end

  def create_user(email, clear_password)
    login = email.split('@')[0]
    domain = email.split('@')[1]
    xml = Nokogiri::XML(RestClient.get "#{URL_API}/api/reg_user.xml", params: {token: @token, login: login, domain: domain,
                                                                                   cryptopasswd: Digest::MD5.hexdigest(clear_password)})
    return true unless xml.xpath('//success').empty?
    false
  end

  def block_user(email)
    set_password(email, SecureRandom.base64)
  end
end