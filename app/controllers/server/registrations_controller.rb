class Server::RegistrationsController < Devise::RegistrationsController
    protected
    def after_sign_up_path_for(resource)
        client_session_login_path
    end
end
