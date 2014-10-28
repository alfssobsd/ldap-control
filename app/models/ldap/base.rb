class Ldap::Base
  @@ldap = nil

  PEOPLE_BASE = "#{Settings.ldap.base_people},#{Settings.ldap.base}".freeze
  GROUP_BASE = "#{Settings.ldap.base_group},#{Settings.ldap.base}".freeze

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
    self.objectclass = self.class::CLASSES
    self.class.init_ldap_connection
  end


  def self.init_ldap_connection
    if @@ldap.nil?
      @@ldap = Net::LDAP.new :host => Settings.ldap.host,
                            :port => Settings.ldap.port,
                            :base => Settings.ldap.base,
                            :auth => {
                                :method => :simple,
                                :username => Settings.ldap.bind_dn,
                                :password => Settings.ldap.password
                            }
    end

    @@people_base  = Settings.ldap.base_people + ',' + Settings.ldap.base
    @@group_base   = Settings.ldap.base_group  + ',' + Settings.ldap.base
  end

  def self.authenticate(dn_attr, login, password)
    ldap =  Net::LDAP.new :host => Settings.ldap.host,
                          :port => Settings.ldap.port,
                          :auth => {
                              :method => :simple,
                              :username => dn_attr + "="+ login + ',' + PEOPLE_BASE,
                              :password => password
                          }
    ldap.bind
  end

  def self.last_error_message
    @@ldap.get_operation_result.error_message
  end
end