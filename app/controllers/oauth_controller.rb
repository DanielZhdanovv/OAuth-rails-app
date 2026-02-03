class OauthController < ApplicationController
    def authorize
        @authorize_request = AuthorizeRequest.new(authorize_params)

        if @authorize_request.valid?

            session[:oauth_params] = {
                client_id: params[:client_id],
                redirect_uri: params[:redirect_uri],
                scope: params[:scope],
                state: params[:state],
                code_challenge: params[:code_challenge],
                code_challenge_method: params[:code_challenge_method]
            }

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
