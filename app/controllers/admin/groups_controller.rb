class Admin::GroupsController < Admin::BaseController

  def index
    @groups = Ldap::Group.all
  end

  def new
    @group = Ldap::Group.new
  end

  def create
    @group = Ldap::Group.new(group_params)
    respond_to do |format|
      if @group.create
        format.html { redirect_to edit_admin_group_path(@group.cn), flash: {success: t('ldap.group.flash.created')} }
      else
        flash.now[:alert] = Ldap::Group.last_error_message unless Ldap::Group.last_error_message.empty?
        format.html { render action: 'new' }
      end
    end
  end

  def edit
    @group = Ldap::Group.find(params[:id])
  end

  def update
    @group = Ldap::Group.find(params[:id])
    respond_to do |format|
      if @group.update(group_params)
        format.html { redirect_to edit_admin_group_path(@group.cn), flash: {success: t('ldap.group.flash.updated')} }
      else
        flash.now[:alert] = Ldap::Group.last_error_message unless Ldap::Group.last_error_message.empty?
        format.html { render action: 'edit' }
      end
    end
  end


  def group_params
    params.require(:ldap_group).permit(:cn, :description, :gidnumber)
  end
end
