class OauthController < ApplicationController
    def authorize
        validate_params
    end

    def validate_params
        errors = []

        errors << "response_type must be code" unless params[:response_type] == "code" || params[:response_type].presence
        errors << "client_id is required" if params[:client_id].blank?
        errors << "redirect_uri is required" if params[:redirect_uri].blank?
        errors << "scope is required" if params[:scope].blank?
        errors << "state is required" if params[:state].blank?
        errors << "code_challenge is required" if params[:code_challenge].blank?
        errors << "code_challenge_method must be S256" unless params[:code_challenge_method] == "S256" || params[:code_challenge_method].presence

        if errors.empty?
            render json: { success: true, message: "Params are valid" }
        else
            render json: { errors: errors }, status: :bad_request
        end
    end
end
