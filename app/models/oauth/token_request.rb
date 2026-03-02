module Oauth
    class TokenRequest
        include ActiveModel::Model
        include ActiveModel::Attributes

        attribute :grant_type, :string
        attribute :code, :string
        attribute :client_id, :string
        attribute :code_verifier, :string

        validates :grant_type, presence: true
        validates :code, presence: true
        validates :client_id, presence: true
        validates :code_verifier, presence: true

        validate :client_exists

    def client_exists
        errors.add(:client_id, "is invalid") if client_id.present? && !Oauth::ClientConfig.exists?(client_id:)
    end

        def initialize(params = {})
            super(params)
        end
    end
end
