class Ldap::Group < Ldap::Entity

  attr_accessor :dn, :cn, :objectclass, :uniquemember, :description, :gidnumber


  CLASSES = ["groupOfUniqueNames", "posixGroup", "top"]
  DN_ATTR = :cn
  ARRAY_ATTR = [:objectclass, :uniquemember]

  validates :dn, length: {in: 1..1000}, presence: true
  validates :description, :cn, length: {in: 1..100}, presence: true
  validates :gidnumber, presence: true, numericality: { only_integer: true, greater_than: 1, less_than: 65000 }

  def initialize(attributes = {})
    self.description = ""
    super
  end

  def dn
    "cn=#{cn},#{GROUP_BASE}"
  end

  class << self

    def search(filter, attrs)
      init_ldap_connection
      @@ldap.search(base: Ldap::Base::GROUP_BASE,
                    filter: filter,
                    attributes: attrs,
                    scope: Net::LDAP::SearchScope_SingleLevel,
                    sort_controls: [DN_ATTR],
                    return_result: true)
    end

    def find(cn)
      filter = Net::LDAP::Filter.eq(DN_ATTR, cn)
      result_list = self.search(filter, Ldap::Group.attributes)
      return nil if result_list.empty?
      obj = new
      obj.mapping(result_list.first)
    end

    def get_person_groups(dn)
      filter = Net::LDAP::Filter.eq(:uniquemember, dn)
      result_list = self.search(filter, Ldap::Group.attributes)
      Ldap::Group.mapping_array(result_list)
    end

    def all
      filter = Net::LDAP::Filter.eq(DN_ATTR, "*")
      result_list = self.search(filter, Ldap::Group.attributes)
      Ldap::Group.mapping_array(result_list)
    end
  end

  def is_member?(dn)
    uniquemember.include?(dn)
  end


  def add_member(dn)
    unless is_member?(dn)
      ops = []
      ops << [:add, :uniquemember, dn]
      @@ldap.modify(dn: self.dn, operations: ops)
    end
  end

  def remove_member(dn)
    if is_member?(dn)
      ops = []
      ops << [:delete, :uniquemember, dn]
      @@ldap.modify(dn: self.dn, operations: ops)
    end
  end

  def create
    if self.valid?
      attrs = {}
      attributes.each do |name|
        attrs[name] = send(name) unless name == :dn or send(name).blank?
      end

      @@ldap.add(dn: self.dn, attributes: attrs)
    end
  end

  def save
    ops = []
    attributes.each do |name|
      ops << [:replace, name, send(name)] unless [:dn, :uniquemember].include?(name) or send(name).blank?
    end
    #создание недостающих классов
    need_add_classes = CLASSES - self.objectclass
    need_add_classes.each do |name_class|
      ops << [:add, :objectclass, name_class]
    end

    @@ldap.modify(dn: self.dn, operations: ops)
  end

  def update(params)
    params.each do |name, value|
      send("#{name}=", value)
    end
    if self.valid?
      save
    end
  end

end