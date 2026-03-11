module Oauth
    class RefreshToken < ApplicationRecord
        belongs_to :user, class_name: "Server::User"
        belongs_to :client_config
        validates :token, presence: true, uniqueness: true
        validates :expires_at, presence: true
        validates :jti, presence: true, uniqueness: true


        def expired?
            expires_at < Time.now
        end

        def revoked?
            revoked_at.present?
        end

        def revoke!
            update!(revoked_at: Time.current)
        end
    end
end
