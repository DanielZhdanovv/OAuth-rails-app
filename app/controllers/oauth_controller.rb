class OauthController < ApplicationController
    def authorize
        authorize_request = Oauth::AuthorizeRequest.new(authorize_params)

        if authorize_request.valid?

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
            callback
        else
            render json: { errors: authorize_request.errors.full_messages }, status: :bad_request
        end
    end

    def callback
        oauth_params = session[:oauth_params]
        client_config = Oauth::ClientConfig.find_by!(client_id: oauth_params["client_id"])

        authorization_code = Oauth::AuthorizationCode.create!(
        code: SecureRandom.urlsafe_base64(32),
        user_id: current_user.id,
        client_config_id: client_config.id,
        code_challenge: oauth_params["code_challenge"],
        )
        after_callback_redirect_uri(oauth_params["redirect_uri"], authorization_code.code, oauth_params["state"])
        session.delete(:oauth_params)
    end

    def after_callback_redirect_uri(redirect_uri, code, state)
        uri = URI.parse(redirect_uri)
        params = Rack::Utils.parse_query(uri.query)

        params["code"] = code
        params["state"] = state if state.present?

        uri.query = params.to_query
        redirect_to uri.to_s
    end

    private

    def authorize_params
        params.permit(:response_type, :client_id, :redirect_uri, :scope, :state, :code_challenge, :code_challenge_method)
    end
end
