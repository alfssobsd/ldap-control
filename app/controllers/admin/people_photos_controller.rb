class Admin::PeoplePhotosController < Admin::BaseController

  def update
    person = Ldap::Person.find(params[:person_id])
    photo = Ldap::PersonPhoto.new({dn: person.dn, uid: person.uid})
    photo.update(people_photo_params)
    redirect_to edit_admin_person_path(person.uid)
  end

  protected

  def people_photo_params
    params.require(:ldap_person_photo).permit(:upload_image)
  end
end
