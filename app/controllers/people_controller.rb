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
    person = Ldap::Person.find(params[:person_id])
    if person
      photo = Ldap::PersonPhoto.new({dn: person.dn, uid: person.uid})
      redirect_to photo.get_url(params[:size])
    else
      photo = Ldap::PersonPhoto.new
      redirect_to photo.get_dummy_url
    end
  end

end
