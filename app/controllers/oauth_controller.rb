class OauthController < ApplicationController
    def authorize
        @authorize_request = AuthorizeRequest.new(authorize_params)
        if @authorize_request.valid?
            unless user_signed_in?
                redirect_to new_user_session_path
                return
            end
            render json: { success: true, message: "Params are valid" }
        else
            render json: { errors: @authorize_request.errors.full_messages }, status: :bad_request
        end
    end

    private

    def authorize_params
        params.permit(:response_type, :client_id, :redirect_uri, :scope, :state, :code_challenge, :code_challenge_method)
    end
end
