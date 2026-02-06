class OauthController < ApplicationController
    def authorize
        @authorize_request = Oauth::AuthorizeRequest.new(authorize_params)

        if @authorize_request.valid?

            session[:oauth_params] = authorize_params.slice(
            :client_id,
            :redirect_uri,
            :scope,
            :state,
            :code_challenge,
            :code_challenge_method
            )

            unless user_signed_in?
                redirect_to new_user_session_path
                return
            end
            redirect_to oauth_callback_path
        else
            render json: { errors: @authorize_request.errors.full_messages }, status: :bad_request
        end
    end

    def callback
        render json: { success: true, message: "Params are valid" }
      # Here I will generate an authorization code and redirect the user
    end


    private

    def authorize_params
        params.permit(:response_type, :client_id, :redirect_uri, :scope, :state, :code_challenge, :code_challenge_method)
    end
end
