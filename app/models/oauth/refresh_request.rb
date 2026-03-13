# frozen_string_literal: true

module Oauth
  # The RefreshRequest class represents a request to refresh an OAuth token
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
      errors.add(:client_id, 'is invalid') if client_id.present? && !Oauth::ClientConfig.exists?(client_id:)
    end

    def refresh_token_exists
      return unless refresh_token.present? && !Oauth::RefreshToken.exists?(token: refresh_token)

      errors.add(:refresh_token,
                 'not found')
    end

    def refresh_token_not_expired
      if defined?(stored_refresh_token)
        stored_refresh_token
      else
        stored_refresh_token = Oauth::RefreshToken.find_by(token: refresh_token)
      end
      return unless stored_refresh_token.present? && stored_refresh_token.expired?

      errors.add(:refresh_token,
                 'has been expired')
    end

    def refresh_token_not_revoked
      if defined?(stored_refresh_token)
        stored_refresh_token
      else
        stored_refresh_token = Oauth::RefreshToken.find_by(token: refresh_token)
      end
      return unless stored_refresh_token.present? && stored_refresh_token.revoked?

      errors.add(:refresh_token,
                 'has been revoked')
    end

    def initialize(params = {})
      super
    end
  end
end
