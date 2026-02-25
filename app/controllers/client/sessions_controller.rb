class Client::SessionsController < ApplicationController
    def login
        code_verifier = SecureRandom.urlsafe_base64(32)
        code_challenge = Digest::SHA256.hexdigest(code_verifier)
        state = SecureRandom.hex(16)
        session[:client] = {}
        session[:client][:code_verifier] = code_verifier
        session[:client][:state] = state

        auth_params = {
            response_type: "code",
            client_id: "client_app_123",
            state: state,
            code_challenge: code_challenge,
            code_challenge_method: "S256"
        }
        redirect_to "/server/oauth/authorize?#{auth_params.to_query}"
    end

    def logout
        sign_out(current_server_user)
        session[:client] = {}
        redirect_to client_root_path, notice: "Logged out successfully."
    end

    def user_registration
        redirect_to new_server_user_registration_path
    end

    def callback
        session[:client][:client_logged_in] = true
        code = params[:code]
        state = params[:state]
        if state != session[:client]["state"]
            render json: { error: "Invalid state" }, status: :bad_request
            return
        end
        render json: { message: "Callback received successfully" }, status: :ok
    end
end
