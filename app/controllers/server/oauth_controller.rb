class Server::OauthController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [ :token ]
    def authorize
        authorize_request = Oauth::AuthorizeRequest.new(authorize_params)
        authorize_request.validate!

        session[:oauth_params] = authorize_request.session_object

        redirect_to server_user_session_path
    rescue ActiveModel::ValidationError => e
        render json: { errors: e.model.errors.full_messages }, status: :bad_request
    end

    def after_login
        login_params = session[:oauth_params]
        authorization_code = Oauth::AuthorizationCode.create!(
            code: SecureRandom.urlsafe_base64(32),
            user_id: current_server_user.id,
            client_config_id: login_params["client_config_id"],
            code_challenge: login_params["code_challenge"],
        )
        session.delete(:oauth_params)
        redirect_to_client(login_params["redirect_uri"], authorization_code.code, login_params["state"])
    end

    def token
        case params[:grant_type]
        when "authorization_code"
            handle_auth_code
        when "refresh_token"
            handle_refresh_token
        else
            render json: { error: "Grant type must be authorization_code or refresh_token" }
        end
    end

    private

    # Issue access_token and refresh_token when client logs in
    def handle_auth_code
        token_request = Oauth::TokenRequest.new(token_params)
        token_request.validate!
        auth_code = Oauth::AuthorizationCode.find_by!(code: params[:code])

        client = Oauth::ClientConfig.find_by!(client_id: params[:client_id])
        unless client && auth_code.client_config_id == client.id
            render json: { error: "Invalid client" }, status: :bad_request
            return
        end

        return unless validate_pkce(auth_code[:code_challenge], token_request.attributes["code_verifier"])

        access_token, refresh_token = generate_tokens(auth_code.user, client)
        auth_code.destroy
        render json: {
            access_token: access_token,
            token_type: "Bearer",
            expires_in: 900,
            refresh_token: refresh_token.token
        }
    rescue ActiveModel::ValidationError => e
        render json: { errors: e.model.errors.full_messages }, status: :bad_request
    rescue ActiveRecord::RecordNotFound
        render json: { errors: "Record not found" }, status: :bad_request
    end

    # Issue new access_token with updated expiration time
    # Issue refresh_token with remaining expiration time
    def handle_refresh_token
        old_refresh_token = Oauth::RefreshToken.find_by(token: params[:refresh_token])
        client = Oauth::ClientConfig.find_by!(client_id: params[:client_id])
        unless client
            render json: { error: "Invalid client" }, status: :bad_request
            return
        end
        unless old_refresh_token
            render json: { error: "Refresh token not found" }, status: :bad_request
            return
        end

        if old_refresh_token.revoked?
            render json: { error: "Refresh token has been revoked" }, status: :bad_request
            return
        end

        if old_refresh_token.expired?
            render json: { error: "Refresh token has been expired" }, status: :bad_request
            return
        end
        access_token, refresh_token = generate_tokens(old_refresh_token.user, client, true)
        render json: {
            access_token: access_token,
            token_type: "Bearer",
            expires_in: 900,
            refresh_token: refresh_token.token
        }
    rescue ActiveModel::ValidationError => e
        render json: { errors: e.model.errors.full_messages }, status: :bad_request
    rescue ActiveRecord::RecordNotFound
        render json: { errors: "Record not found" }, status: :bad_request
    end

    def validate_pkce(stored_challenge, code_verifier)
        digest = Digest::SHA256.digest(code_verifier)
        computed_server_challenge = Base64.urlsafe_encode64(digest, padding: false)

        unless stored_challenge == computed_server_challenge
            render json: { error: "Failed PKCE verification" }, status: :bad_request
            return false
        end
        true
    end
    def generate_tokens(user, client, rotate = false)
        jti_var = SecureRandom.uuid

        access_token_payload = {
            user_id: user,
            client_config_id: client.id,
            expires_at: 15.minutes.from_now,
            jti: jti_var, # Unique id
            iss: "Server_app", # Who issued
            aud: client.client_id # Who should use it
        }
        access_token = JWT.encode(access_token_payload, Rails.application.credentials.secret_key_base, "HS256")
        if rotate
            old_refresh_token = Oauth::RefreshToken.find_by(token: params[:refresh_token])
            refresh_token = Oauth::RefreshToken.create!(
                token: SecureRandom.urlsafe_base64(32),
                user: user,
                client_config_id: client.id,
                expires_at: old_refresh_token.expires_at,
                jti: jti_var
            )
            old_refresh_token.revoke!
        else
            refresh_token = Oauth::RefreshToken.create!(
                token: SecureRandom.urlsafe_base64(32),
                user: user,
                client_config_id: client.id,
                expires_at: 30.minutes.from_now,
                jti: jti_var
            )
        end
        [ access_token, refresh_token ]
    end

    def redirect_to_client(redirect_uri, code, state)
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

    def token_params
        params.permit(:grant_type, :code, :client_id, :code_verifier)
    end
end
