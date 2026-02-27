module Oauth
    class CallbackRequest
        include ActiveModel::Model
        include ActiveModel::Attributes

        attribute :client_id, :string
        attribute :state, :string
        attribute :code_challenge, :string

        validates :client_id, presence: true
        validates :state, presence: true
        validates :code_challenge, presence: true
        validate :client_exists

        def client_exists
            errors.add(:client_id, "is invalid") if client_id.present? && !Oauth::ClientConfig.exists?(client_id:)
        end

        def initialize(params = {})
            super(params)
        end
    end
end
