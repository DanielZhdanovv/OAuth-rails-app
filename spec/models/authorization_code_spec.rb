require "rails_helper"

RSpec.describe Oauth::AuthorizationCode, type: :model do
  subject(:auth_code) { described_class.new(code:, user:, client_config:, code_challenge:) }

  let(:user) { Oauth::User.create!(first_name: "Adam", last_name: "Smith", email: "test@example.com", password: "password12345") }
  let(:client_config) { Oauth::ClientConfig.create!(name: "Test Client", client_id: "test_client", redirect_uri: "http://localhost:3000") }
  let(:code) { SecureRandom.urlsafe_base64(32) }
  let(:code_challenge) { "some-code-challenge" }


    describe "validations" do
        it "is valid with required attributes" do
            expect(auth_code).to be_valid
        end
        context "when user is missing" do
            let(:user) { nil }
            it "requires a user" do
                expect(auth_code).not_to be_valid
                expect(auth_code.errors[:user]).to include("must exist")
            end
        end
        context "when client_config is missing" do
            let(:client_config) { nil }
            it "requires a client_config" do
                expect(auth_code).not_to be_valid
                expect(auth_code.errors[:client_config]).to include("must exist")
            end
        end
        context "when code is missing" do
            let(:code) { nil }
            it "requires a code" do
                expect(auth_code).not_to be_valid
                expect(auth_code.errors[:code]).to include("can't be blank")
            end
        end
        context "when code_challenge is missing" do
            let(:code_challenge) { nil }
            it "requires a code_challenge" do
                expect(auth_code).not_to be_valid
                expect(auth_code.errors[:code_challenge]).to include("can't be blank")
            end
        end
    end
end
