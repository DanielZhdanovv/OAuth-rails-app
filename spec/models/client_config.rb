require "rails_helper"

RSpec.describe Oauth::ClientConfig, type: :model do
subject(:client_config) { described_class.new(name:, client_id:, redirect_uri:) }
    let(:name) { "Test Client" }
    let(:client_id) { "test_client" }
    let(:redirect_uri) { "http://localhost:3000" }

    describe "validations" do
        it "is valid with required attributes" do
            expect(client_config).to be_valid
        end
        context "when name is missing" do
            let(:name) { nil }
            it "requires a name" do
                expect(client_config).not_to be_valid
                expect(client_config.errors[:name]).to include("can't be blank")
            end
        end
        context "when client_id is missing" do
            let(:client_id) { nil }
            it "requires a client_id" do
                expect(client_config).not_to be_valid
                expect(client_config.errors[:client_id]).to include("can't be blank")
            end
        end
        context "when redirect_uri is missing" do
            let(:redirect_uri) { nil }
            it "requires a redirect_uri" do
                expect(client_config).not_to be_valid
                expect(client_config.errors[:redirect_uri]).to include("can't be blank")
            end
        end
    end
end
