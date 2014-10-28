class Ldap::GroupMember < Ldap::Entity
  attr_accessor :dn, :objectclass

  DN_ATTR = :dn
  CLASSES = [:objectclass]

  #DUMMY
end