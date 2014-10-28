class PeopleController < BaseController
  def index
    @peoples = Ldap::Person.find_by_employeetype("staff")
  end

  def show
    @person = Ldap::Person.find(params[:id])
  end

  def photo
    person = Ldap::Person.find(params[:person_id])
    photo = Ldap::PersonPhoto.new({dn: person.dn, uid: person.uid})
    redirect_to photo.get_url(params[:size])
  end

end
