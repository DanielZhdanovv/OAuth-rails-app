class Server::OauthController < ApplicationController
    def authorize
        authorize_request = Oauth::AuthorizeRequest.new(authorize_params)
        authorize_request.validate!

            session[:oauth_params] = authorize_params.slice(
            :client_id,
            :scope,
            :state,
            :code_challenge,
            :code_challenge_method,
            :response_type
            )

        redirect_to new_user_session_path
    rescue ActiveModel::ValidationError => e
        render json: { errors: e.model.errors.full_messages }, status: :bad_request
    end

    def redirect_to_client
        callback_request = Oauth::CallbackRequest.new(authorize_params)
        callback_request.validate!
        client_config = Oauth::ClientConfig.find_by!(client_id: callback_request.attributes["client_id"])

        authorization_code = Oauth::AuthorizationCode.create!(
        code: SecureRandom.urlsafe_base64(32),
        user_id: current_user.id,
        client_config_id: client_config.id,
        code_challenge: callback_request.attributes["code_challenge"],
        )
        after_callback_redirect_uri(client_config["redirect_uri"], authorization_code.code, callback_request.attributes["state"])
        session.delete(:oauth_params)
    rescue ActiveModel::ValidationError => e
        render json: { errors: e.model.errors.full_messages }, status: :bad_request
    end

    private

    def after_callback_redirect_uri(redirect_uri, code, state)
        uri = URI.parse(redirect_uri)
        params = Rack::Utils.parse_query(uri.query)

        params["code"] = code
        params["state"] = state if state.present?

        uri.query = params.to_query
        redirect_to uri.to_s, allow_other_host: true
    end

    def authorize_params
        params.permit(:response_type, :client_id, :state, :code_challenge, :code_challenge_method)
    end
end
