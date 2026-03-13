# frozen_string_literal: true

module Server
  # The SessionsController class handles user sessions and authentication for the server
  class SessionsController < Devise::SessionsController
    protected

    def after_sign_in_path_for(_resource)
      if session['oauth_params'].present?
        server_oauth_after_login_path(session['oauth_params'])
      else
        client_root_path
      end
    end
  end
end
