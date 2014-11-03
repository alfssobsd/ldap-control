class Api::BaseController < ApplicationController
  def authenticate_api_public
    warden.authenticate! scope: :api_public
  end
end
