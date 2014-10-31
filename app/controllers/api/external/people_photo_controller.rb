class Api::External::PeoplePhotoController < Api::BaseController
  before_filter :restrict_access_public

  def show
    params[:size] ||= 'small'
    person = Ldap::Person.find(params[:id])
    if person
      photo = Ldap::PersonPhoto.new({dn: person.dn, uid: person.uid})
      redirect_to photo.get_url(params[:size])
    else
      photo = Ldap::PersonPhoto.new
      redirect_to photo.get_dummy_url
    end
  end
end
