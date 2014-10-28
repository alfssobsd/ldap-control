class ProfilesController < BaseController
  before_filter :set_person
  before_filter :set_person_photo

  def edit
  end

  def update_passowrd
    respond_to do |format|
      if @person.update(update_passowrd_params)
        format.html { redirect_to edit_profile_path, flash: {success: t('ldap.person_password.flash.updated')} }
      else
        flash.now[:alert] = Ldap::Person.last_error_message unless Ldap::Person.last_error_message.empty?
        format.html { render action: 'edit' }
      end
    end
  end

  def update_photo
    @person_photo.dn = @person.dn
    @person_photo.update(update_photo_params)
    respond_to do |format|
      if @person_photo.update(update_photo_params)
        format.html { redirect_to edit_profile_path, flash: {success: t('ldap.person_photo.flash.updated')} }
      else
        flash.now[:alert] = Ldap::PersonPhoto.last_error_message unless Ldap::PersonPhoto.last_error_message.empty?
        format.html { render action: 'edit' }
      end
    end
  end

  protected

  def update_passowrd_params
    params.require(:ldap_person).permit(:password, :password_confirmation)
  end

  def update_photo_params
    params.fetch(:ldap_person_photo, {}).permit(:upload_image)
  end

  def set_person
    @person = current_user
  end

  def set_person_photo
    @person_photo = Ldap::PersonPhoto.new
  end
end
