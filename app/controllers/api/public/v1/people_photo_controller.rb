class Api::Public::V1::PeoplePhotoController < Api::Public::BaseController
  def show
    params[:size] ||= 'small'
    person = Ldap::Person.find(params[:id]) || Ldap::Person.new
    photo = Ldap::PersonPhoto.new({dn: person.dn, uid: person.uid})
    send_file photo.get(params[:size]), type: 'image/jpeg', disposition: 'inline'
  end
end
