class SessionsController < ApplicationController
  layout 'session'
  before_filter :person_object

  def new
  end

  def create
    person = Ldap::Person.authenticate(auth_params[:uid], auth_params[:password])
    if person
      session[:person] = person.uid
      if session[:previous_url]
        previous_url = session[:previous_url]
        session[:previous_url] = nil
        redirect_to previous_url
      else
        redirect_to root_path
      end
    else
      flash.now[:alert] = "Incorrect Login or Password"
      session[:person] = nil
      render :new
    end
  end


  def destroy
    session[:person] = nil
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
