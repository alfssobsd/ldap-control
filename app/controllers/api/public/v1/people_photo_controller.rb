class Api::Public::V1::PeoplePhotoController < Api::Public::BaseController
  def show
    params[:size] ||= 'small'
    person = Ldap::Person.find(params[:id])
    if person
      photo = Ldap::PersonPhoto.new({dn: person.dn, uid: person.uid})
      redirect_to photo.get_url(params[:size]), :status => 301
    else
      photo = Ldap::PersonPhoto.new
      redirect_to photo.get_dummy_url
    end
  end
end
