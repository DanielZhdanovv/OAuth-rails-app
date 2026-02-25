module Oauth
    class AuthorizeRequest
        include ActiveModel::Model
        include ActiveModel::Attributes

        attribute :response_type, :string
        attribute :client_id, :string
        attribute :state, :string
        attribute :code_challenge, :string
        attribute :code_challenge_method, :string

        validates :response_type, presence: true, inclusion: { in: [ "code" ] }
        validates :client_id, presence: true
        validates :state, presence: true
        validates :code_challenge, presence: true
        validates :code_challenge_method, presence: true, inclusion: { in: [ "S256" ] }
        validate :client_exists

    def client_exists
        errors.add(:client_id, "is invalid") if client_id.present? && !Oauth::ClientConfig.exists?(client_id:)
    end

        def initialize(params = {})
            super(params)
        end
    end
end
