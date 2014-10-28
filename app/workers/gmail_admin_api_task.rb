class GmailAdminApiTask
  @queue = :external_services
  def self.perform(uid, clear_password)
    person = Ldap::Person.find(uid)
    group = Ldap::Group.find(Settings.google.gmail_admin.group)
    domains = Settings.google.gmail_admin.domains
    if person and group.is_member?(person.dn)
      gmail = GmailAdminApi.new
      update_account_list = []
      person.mail.each do |mail|
        login, domain = mail.split('@')
        update_account_list << mail if domains.include?(domain)
      end

      update_account_list.each do |account|
         if gmail.exist?(account)
           gmail.set_password(account, clear_password)
         end
      end
    end
  end
end