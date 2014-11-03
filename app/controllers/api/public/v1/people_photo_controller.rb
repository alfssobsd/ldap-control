class Api::Public::V1::PeoplePhotoController < Api::Public::BaseController
  def show
    params[:size] ||= 'small'
    person = Ldap::Person.find(params[:id])
    if person
      photo = Ldap::PersonPhoto.new({dn: person.dn, uid: person.uid})
      send_file photo.get(params[:size]), type: 'image/jpeg', disposition: 'inline'
    else
      photo = Ldap::PersonPhoto.new
      send_file photo.get_dummy, type: 'image/jpeg', disposition: 'inline'
    end
  end
end
