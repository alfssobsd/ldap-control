class Api::BaseController < ApplicationController
  def restrict_access_public
    unless Settings.api.public.keys.include?(params[:api_key])
      return render status: :forbidden, text: "Forbidden"
    end
  end
end
