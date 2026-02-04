require "rails_helper"

RSpec.describe Oauth::AuthorizationCode, type: :model do
    let(:user) { Oauth::User.create!(first_name: 'Adam', last_name: 'Smith', email: 'test@example.com', password: 'password12345') }
    let(:client_config) { ClientConfig.create!(name: 'Test Client', client_id: 'test_client', redirect_uri: 'http://localhost:3000') }

    let(:valid_params) do
        {
            response_type: "code",
            client_id: "test_client",
            redirect_uri: "http://localhost:3000",
            scope: "user info",
            state: "state1",
            code_challenge: "code_challenge_12345",
            code_challenge_method: "S256"
        }
    end
    
    describe 'authorization code creation' do
        context 'with valid attributes' do
            it 'creates an authorization code' do
                auth_code = Oauth::AuthorizationCode.new(
                    code: SecureRandom.urlsafe_base64(32),
                    user: user,
                    client_config: client_config,
                    code_challenge: valid_params[:code_challenge]
                )
                expect(auth_code).to be_valid
            end
        end

        context 'with invalid attributes' do
            it 'is not valid without a user' do
                auth_code = Oauth::AuthorizationCode.new(
                    code: SecureRandom.urlsafe_base64(32),
                    client_config: client_config,
                    code_challenge: valid_params[:code_challenge]
                )
                expect(auth_code).not_to be_valid
            end

            it 'is not valid without a client_config' do
                auth_code = Oauth::AuthorizationCode.new(
                    code: SecureRandom.urlsafe_base64(32),
                    user: user,
                    code_challenge: valid_params[:code_challenge]
                )
                expect(auth_code).not_to be_valid
            end
        end
    end
end