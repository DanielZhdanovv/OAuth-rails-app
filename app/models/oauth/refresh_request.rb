module Oauth
    class RefreshRequest
        include ActiveModel::Model
        include ActiveModel::Attributes

        attribute :client_id, :string
        attribute :refresh_token, :string

        validates :client_id, presence: true
        validates :refresh_token, presence: true

        validate :client_exists
        validate :refresh_token_exists
        validate :refresh_token_not_expired
        validate :refresh_token_not_revoked

    def client_exists
        errors.add(:client_id, "is invalid") if client_id.present? && !Oauth::ClientConfig.exists?(client_id:)
    end

    def refresh_token_exists
        errors.add(:refresh_token, "not found") if refresh_token.present? && !Oauth::RefreshToken.exists?(token: refresh_token)
    end

    def refresh_token_not_expired
        @stored_refresh_token ||= Oauth::RefreshToken.find_by(token: refresh_token)
        errors.add(:refresh_token, "has been expired") if @stored_refresh_token.present? && @stored_refresh_token.expired?
    end

    def refresh_token_not_revoked
        @stored_refresh_token ||= Oauth::RefreshToken.find_by(token: refresh_token)
        errors.add(:refresh_token, "has been revoked") if @stored_refresh_token.present? && @stored_refresh_token.revoked?
    end

        def initialize(params = {})
            super(params)
        end
    end
end
