#TODO: нужен автоинкримент uidnumber
class Ldap::Person < Ldap::Entity

  attr_accessor :dn, :objectclass, :uid, :cn, :sn, :givenname, :l, :o, :mail, :skype, :title,
                :employeetype, :mobile, :uidnumber, :gidnumber, :homedirectory, :password

  DN_ATTR = :uid
  CLASSES = ["person", "inetOrgPerson", "organizationalPerson", "posixAccount", "top", "vuaro"]
  ARRAY_ATTR = [:mail, :objectclass, :mobile]
  EMPLOY_TYPES = %w(staff fired external parnter system)

  validates :dn, length: {in: 1..1000}, presence: true
  validates :givenname, :sn, :l, :o, :skype, :title, length: {in: 1..100}, presence: true
  validates :uid, length: {in: 1..100}, presence: true, format: { with: /\A[a-zA-Z\.\_\-]+\z/ }
  validates :objectclass, :mail, :mobile, presence: true
  validates :employeetype, presence: true, inclusion: EMPLOY_TYPES
  validates :password, length: { minimum: 8 }, confirmation: true, allow_blank: true
  validates :uidnumber, :gidnumber, presence: true, numericality: { only_integer: true, greater_than: 1, less_than: 65000 }

  class << self

    def search(filter, attrs)
      init_ldap_connection
      @@ldap.search(base: Ldap::Base::PEOPLE_BASE,
                    filter: filter,
                    attributes: attrs,
                    scope: Net::LDAP::SearchScope_SingleLevel,
                    sort_controls: [DN_ATTR],
                    return_result: true)
    end

    def find_by_filter(filter)
      #filter = Net::LDAP::Filter.eq(DN_ATTR, uid)
      result = self.search(filter, Ldap::Person.attributes)
      Ldap::Person.mapping_array(result)
    end

    def all
      filter = Net::LDAP::Filter.eq(DN_ATTR, "*")
      find_by_filter(filter)
    end

    def find(uid)
      filter = Net::LDAP::Filter.eq(DN_ATTR, uid)
      result = find_by_filter(filter)
      result.first
    end

    def find_by_employeetype(employeetype)
      filter_dn = Net::LDAP::Filter.eq(DN_ATTR, "*")
      filter_employeetype = Net::LDAP::Filter.eq(:employeetype, employeetype)
      find_by_filter(Net::LDAP::Filter.join(filter_employeetype, filter_dn))
    end

    def authenticate(uid, password)
      if self.valid_attribute?(:uid, uid)
        return self.find(uid) if Ldap::Base.authenticate(DN_ATTR.to_s, uid, password)
      end
      nil
    end

    def valid_attribute?(attr, value)
      mock = self.new(attr => value)
      if mock.valid?
        true
      else
        !mock.errors.has_key?(attr)
      end
    end
  end

  def initialize(attributes = {})
    self.mail = [""]
    self.mobile = [""]
    super
  end

  def dn
    "uid=#{uid},#{PEOPLE_BASE}"
  end

  def cn
    "#{givenname} #{sn}"
  end

  def homedirectory
    "/home/#{uid}"
  end

  def groups
    Ldap::Group.get_person_groups(self.dn)
  end


  #methods ldap
  def save
    self.password = nil
    ops = []
    self.cn = "#{givenname} #{sn}"
    attributes.each do |name|
      ops << [:replace, name, send(name)] unless name == :dn or send(name).blank?
    end

    #создание недостающих классов
    need_add_classes = CLASSES - self.objectclass
    need_add_classes.each do |name_class|
      ops << [:add, :objectclass, name_class]
    end

    @@ldap.modify(dn: self.dn, operations: ops)
  end

  def create
    result = true
    clear_password = self.password
    if self.valid?
      self.password = nil
      attrs = {}
      attributes.each do |name|
        attrs[name] = send(name) unless name == :dn or send(name).blank?
      end

      result = @@ldap.add(dn: self.dn, attributes: attrs)
    end

    self.password = clear_password
    result and update_password
  end

  def update(params)
    if params[:password].blank?
      params.delete(:password_confirmation)
      params.delete(:password)
    end

    params.each do |name, value|
      send("#{name}=", value)
    end

    if self.valid?
      update_password and save
    end
  end

  protected

  def update_password
    if self.password and !self.password.empty?
      result =  @@ldap.replace_attribute self.dn, :userPassword, generate_hash_password(self.password)
      if result
        Resque.enqueue(GmailAdminApiTask, self.uid, self.password)
      end
      return result
    end
    true
  end

  #Only SSHA
  def generate_hash_password(secret)
    salt = SecureRandom.hex(8)
    "{SSHA}"+Base64.encode64(Digest::SHA1.digest(secret + salt) + salt).chomp!
  end

end