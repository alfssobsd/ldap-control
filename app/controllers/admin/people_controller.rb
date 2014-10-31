class Admin::PeopleController < Admin::BaseController

  def index
    employeetype = params[:employeetype]
    employeetype ||= "staff"
    employeetype = "*" if employeetype == "all"

    @peoples = Ldap::Person.find_by_employeetype(employeetype)
  end

  def show

  end

  def new
    @person = Ldap::Person.new
  end

  def create
    @person = Ldap::Person.new(person_params)
    respond_to do |format|
      if @person.create
        format.html { redirect_to edit_admin_person_path(@person.uid), flash: {success: t('ldap.person.flash.created')} }
      else
        flash.now[:alert] = Ldap::Person.last_error_message unless Ldap::Person.last_error_message.empty?
        format.html { render action: 'new' }
      end
    end
  end

  def edit
    @person_photo = Ldap::PersonPhoto.new
    @person = Ldap::Person.find(params[:id])
  end


  #TODO: нужно доделать редактирование мульти записей (mail, phone)
  def update
    @person_photo = Ldap::PersonPhoto.new
    @person = Ldap::Person.find(params[:id])
    respond_to do |format|
      if @person.update(person_params)
        format.html { redirect_to edit_admin_person_path(@person.uid), flash: {success: t('ldap.person.flash.updated')} }
      else
        flash.now[:alert] = Ldap::Person.last_error_message unless Ldap::Person.last_error_message.empty?
        format.html { render action: 'edit' }
      end
    end
  end

  def destroy

  end


  protected

  def person_params
    params.require(:ldap_person).permit(:uid, :cn, :sn, :givenname, :l, :o, :skype, :title,
                                        :employeetype, :uidnumber, :gidnumber, :mobile, :password, :password_confirmation, :mobile => [], :mail => [])
  end

end
