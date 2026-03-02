require "http"
class Client::SessionsController < ApplicationController
    def login
        code_verifier = SecureRandom.urlsafe_base64(32)
        digest = Digest::SHA256.digest(code_verifier)
        code_challenge = Base64.urlsafe_encode64(digest, padding: false)
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
        request_tokens(code, state)
    end

    def refresh_tokens
            response = HTTP.headers(accept: "application/json").post("http://localhost:3000/server/oauth/token", form: {
            grant_type: "refresh_token",
            client_id: "client_app_123",
            refresh_token: session["client"]["refresh_token"]
        })

        if response.status.success?
            token_data = JSON.parse(response.body)
            session[:client][:access_token] = token_data["access_token"]
            session[:client][:refresh_token] = token_data["refresh_token"]
            redirect_to client_root_path, notice: "Your refreshed your token!"
        else
            render json: { error: "it didnt work" }
        end
    end

    private

    def request_tokens(code, state)
            response = HTTP.headers(accept: "application/json").post("http://localhost:3000/server/oauth/token", form: {
            grant_type: "authorization_code",
            code: code,
            client_id: "client_app_123",
            code_verifier: session[:client]["code_verifier"]
        })
        if response.status.success?
            token_data = JSON.parse(response.body)
            session[:client][:access_token] = token_data["access_token"]
            session[:client][:refresh_token] = token_data["refresh_token"]
            redirect_to client_root_path
        else
            render json: { error: "it didnt work" }
        end
    end
end
