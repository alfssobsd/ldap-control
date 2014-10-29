class SessionsController < ApplicationController
  layout 'session'
  before_filter :person_object

  def new
    flash.now.alert = warden.message if warden.message.present?
  end

  def create
    person = warden.authenticate!
    if person
      if session[:previous_url]
        previous_url = session[:previous_url]
        session[:previous_url] = nil
        redirect_to previous_url
      else
        redirect_to root_path
      end
    end
  end


  def destroy
    warden.logout
    redirect_to new_sessions_path
  end


  protected
  def auth_params
    params.require(:ldap_person).permit(:uid, :password)
  end

  def person_object
    @person = Ldap::Person.new
  end

  def valid_auth_params?
    auth_params[:uid] || auth_params[:password]
  end
end
