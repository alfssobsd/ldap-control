class Api::Public::BaseController <  Api::BaseController
  before_filter :authenticate_api_public
end
