# frozen_string_literal: true

module Oauth
  # The AuthorizationCode model represents an authorization code issued to a client
  class AuthorizationCode < ApplicationRecord
    belongs_to :user, class_name: 'Server::User'
    belongs_to :client_config
    validates :code, presence: true, uniqueness: true
    validates :code_challenge, presence: true
  end
end
