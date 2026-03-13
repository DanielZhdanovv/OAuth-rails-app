# frozen_string_literal: true

module Server
  # The RegistrationsController class handles user registrations for the server
  class RegistrationsController < Devise::RegistrationsController
    protected

    def after_sign_up_path_for(_resource)
      client_session_login_path
    end
  end
end
