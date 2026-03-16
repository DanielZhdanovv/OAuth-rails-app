# frozen_string_literal: true

module Server
  # UsersController handles user related actions for the server application
  class UsersController < ApplicationController
    def show # rubocop:disable Metrics/AbcSize
      token = request.headers['Authorization']&.split&.last

      decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base, true, algorithm: 'HS256')
      user_id = decoded_token[0]['user_id']
      user = Server::User.find(user_id)
      render json: { first_name: user.first_name, last_name: user.last_name, email: user.email }
    rescue JWT::ExpiredSignature
      render json: { error: 'Token has expired' }, status: :unauthorized
    rescue JWT::DecodeError
      render json: { error: 'Invalid token' }, status: :unauthorized
    end
  end
end
