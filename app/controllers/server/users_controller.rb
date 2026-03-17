# frozen_string_literal: true

module Server
  # UsersController handles user related actions for the server application
  class UsersController < ApplicationController
    # token decoding & Server::User querying done in authenticate method
    before_action :authenticate

    def show
      render json: { first_name: @user.first_name, last_name: @user.last_name, email: @user.email }
    rescue StandardError => e
      render json: { error: e.message }, status: e.status
    end

    def authenticate
      @token = request.headers['Authorization']&.split&.last

      decoded_token = JWT.decode(@token, Rails.application.credentials.secret_key_base, true, algorithm: 'HS256')
      user_id = decoded_token[0]['user_id']

      @user = Server::User.find(user_id)
    end
  end
end
