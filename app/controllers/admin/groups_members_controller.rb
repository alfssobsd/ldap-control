class Admin::GroupsMembersController < ApplicationController
  before_filter :set_group

  def create
    @group.add_member(group_members_params[:dn])
    redirect_to edit_admin_group_path(@group.cn), flash: {notice: "#{t('ldap.group.member.flash.create')} #{group_members_params[:dn]}" }
  end

  def destroy
    @group.remove_member(group_members_params[:dn])
    redirect_to edit_admin_group_path(@group.cn), flash: {notice: "#{t('ldap.group.member.flash.destroy')} #{group_members_params[:dn]}" }
  end

  protected

  def set_group
    @group = Ldap::Group.find(params[:group_id])
  end

  def group_members_params
    params.require(:ldap_group_member).permit(:dn)
  end
end
