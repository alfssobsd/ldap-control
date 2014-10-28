class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def authenticate_user
    unless signed_in?
      store_location
      redirect_to new_sessions_path, notice: "Please sign in."
    end
  end

  def signed_in?
    return true if session[:person] and Ldap::Person.find(session[:person])
    session[:person] = nil if session[:person]
    false
  end

  def store_location
    # store last url - this is needed for post-login redirect to whatever the user last visited.
    if  request.fullpath != "/sessions" &&
        request.fullpath != "/sessions/new" &&
        !request.xhr? # don't store ajax calls
      session[:previous_url] = request.fullpath
    end
  end

  def current_user
    @current_user ||= Ldap::Person.find(session[:person]) if session[:person]
  end

  helper_method :current_user


  def person_photo(uid, size)
    person = Ldap::Person.find(uid)
    photo = Ldap::PersonPhoto.new({dn: person.dn, uid: person.uid})
    redirect_to photo.get_url(size)
  end
end
