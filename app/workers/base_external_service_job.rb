class BaseExternalServiceJob
  @group_name = "not_exsit_external_service_group"
  @domains = nil
  @service_class = nil

  def self.perform(uid, clear_password)
    person = Ldap::Person.find(uid)
    group = Ldap::Group.find(@group_name)
    if person and group.is_member?(person.dn)
      accounts_list = []
      if @domains
        person.mail.each do |mail|
          login, domain = mail.split('@')
          accounts_list << mail if @domains.include?(domain)
        end
      else
        accounts_list = [person.uid]
      end

      self.run(person, clear_password, accounts_list)
    end
  end

  def self.run(person, clear_password, accounts_list)
    external_service = Class.new(@service_class).new(Resque.logger)
    accounts_list.each do |account|
      is_exist = external_service.exist?(account)
      if is_exist and person.employeetype == "fired"
        Resque.logger.debug("#{@service_class} DEACTIVATE #{account}")
        external_service.deactivate(account)
      elsif !is_exist and !clear_password.blank? and !person.mail.blank?
        Resque.logger.debug("#{@service_class} CREATE #{account}")
        external_service.create(account, person.givenname, person.sn, person.mail.first, clear_password)
      elsif is_exist

        unless external_service.is_actived?(account)
          Resque.logger.debug("#{@service_class} ACTIVATE #{account}")
          external_service.activate(account)
        end

        unless person.mail.blank?
          Resque.logger.debug("#{@service_class} UPDATE #{account}")
          external_service.update(account, person.givenname, person.sn, person.mail.first,)
        end

        unless clear_password.blank?
          Resque.logger.debug("#{@service_class} SET PASSWORD #{account}")
          external_service.set_password(account, clear_password)
        end
      else
        Resque.logger.debug("#{@service_class} not found action for #{account}")
      end
    end
  end
end