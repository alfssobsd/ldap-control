class PeopleController < BaseController

  def index
    employeetype_list = %w(external staff partner)
    filters = employeetype_list.map { |name| Net::LDAP::Filter.eq(:employeetype, name) }
    search_filter = Net::LDAP::Filter.construct("(|#{ filters.join("") })")
    @peoples = Ldap::Person.find_by_filter(search_filter)
  end

  def show
    @person = Ldap::Person.find(params[:id])
  end

  def photo
    params[:size] ||= 'small'
    person = Ldap::Person.find(params[:person_id]) || Ldap::Person.new
    photo = Ldap::PersonPhoto.new({dn: person.dn, uid: person.uid})
    send_file photo.get(params[:size]), type: 'image/jpeg', disposition: 'inline'
  end

end
