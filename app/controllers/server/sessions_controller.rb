class Server::SessionsController < Devise::SessionsController
    protected
  def after_sign_in_path_for(resource)
    if session["oauth_params"].present?
      server_oauth_redirect_to_client_path(session["oauth_params"])
    else
      client_root_path
    end
  end
end
