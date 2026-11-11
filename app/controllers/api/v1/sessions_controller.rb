module Api
  module V1
    class SessionsController < BaseController
      allow_unauthenticated_access only: :create
      rate_limit to: 10, within: 3.minutes, only: :create, with: -> { render json: { error: "too_many_requests" }, status: :too_many_requests }

      # POST /api/v1/session  (login)
      def create
        if user = User.authenticate_by(username: params[:username].to_s.strip.downcase, password: params[:password])
          start_new_session_for user
          render json: user
        else
          render json: { error: "invalid_credentials" }, status: :unauthorized
        end
      end

      # DELETE /api/v1/session  (logout)
      def destroy
        terminate_session
        head :no_content
      end
    end
  end
end
