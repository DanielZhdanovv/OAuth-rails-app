class OauthController < ApplicationController
    def authorize
        validate_params
        if @validation_errors.empty?
            store_oauth_params
            render json: { success: true, message: "Params are valid" }
        else
            render json: { errors: @validation_errors }, status: :bad_request
        end
    end

    def validate_params
        @validation_errors = []

        @validation_errors << "response_type must be code" unless params[:response_type] == "code"
        @validation_errors << "client_id is required" if params[:client_id].blank?
        @validation_errors << "redirect_uri is required" if params[:redirect_uri].blank?
        @validation_errors << "scope is required" if params[:scope].blank?
        @validation_errors << "state is required" if params[:state].blank?
        @validation_errors << "code_challenge is required" if params[:code_challenge].blank?
        @validation_errors << "code_challenge_method must be S256" unless params[:code_challenge_method] == "S256"
    end

    def store_oauth_params
        session[:oauth_params] = {
            client_id: params[:client_id],
            redirect_uri: params[:redirect_uri],
            state: params[:state],
            code_challenge: params[:code_challenge],
            scope: params[:scope]
        }
    end
end
