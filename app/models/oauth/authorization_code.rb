module Oauth
    class AuthorizationCode < ApplicationRecord
        belongs_to :user
        belongs_to :client_config
        validates :code, presence: true, uniqueness: true
        validates :code_challenge, presence: true
    end
end
