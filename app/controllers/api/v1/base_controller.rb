module Api
  module V1
    # JSON API. Uses the same session cookie as the web pages.
    class BaseController < ApplicationController
      skip_forgery_protection

      private
        def request_authentication
          render json: { error: "unauthorized" }, status: :unauthorized
        end
    end
  end
end
