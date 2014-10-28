class Admin::BaseController < ApplicationController
  layout 'admin'
  before_filter :authenticate_user
  before_filter :only_admin

  def only_admin
    person = Ldap::Person.new
    authorize! :manage, person
  end

end
