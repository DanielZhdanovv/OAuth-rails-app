require "rails_helper"

RSpec.describe Server::OauthController, type: :controller do
    include Devise::Test::ControllerHelpers
    describe "GET #authorize" do
        let(:user) { Oauth::User.create!(first_name: 'Adam', last_name: 'Smith', email: 'test@example.com', password: 'password12345') }
        let(:client_config) { Oauth::ClientConfig.create!(name: "Test Client", client_id: "test_client", redirect_uri: "http://localhost:3000") }
        let(:valid_params) do
            {
                response_type: "code",
                client_id: "test_client",
                state: "state1",
                code_challenge: "code_challenge_12345",
                code_challenge_method: "S256"
            }
        end

        before do
            request.host = 'localhost'
            request.port = 3000
            new_user_session_path
            sign_in(user, scope: :user)
        end
        context 'with valid params' do
            context "in authorize" do
                it "redirects to user login page" do
                    get :authorize, params: valid_params.merge(client_config_id: client_config.id)
                    expect(response).to redirect_to(new_user_session_path)
                end
            end
        end
        context 'with invalid params' do
            context "when response_type is invalid" do
                it "returns error" do
                    params = valid_params.except(:response_type)
                    get :authorize, params: params

                    expect(response).to have_http_status(:bad_request)
                    response_body = JSON.parse(response.body)
                    expect(response_body["errors"]).to include("Response type can't be blank", "Response type is not included in the list")
                end
            end

            context "when client_id is missing" do
                it "returns error" do
                    params = valid_params.except(:client_id)
                    get :authorize, params: params

                    expect(response).to have_http_status(:bad_request)
                    response_body = JSON.parse(response.body)
                    expect(response_body["errors"]).to include("Client can't be blank")
                end
            end
            context "when state is missing" do
                it "returns error" do
                    params = valid_params.except(:state)
                    get :authorize, params: params

                    expect(response).to have_http_status(:bad_request)
                    response_body = JSON.parse(response.body)
                    expect(response_body["errors"]).to include("State can't be blank")
                end
            end
            context "when code_challenge is missing" do
                it "returns error" do
                    params = valid_params.except(:code_challenge)
                    get :authorize, params: params

                    expect(response).to have_http_status(:bad_request)
                    response_body = JSON.parse(response.body)
                    expect(response_body["errors"]).to include("Code challenge can't be blank")
                end
            end
            context "when code_challenge_method is missing" do
                it "returns error" do
                    params = valid_params.except(:code_challenge_method)
                    get :authorize, params: params

                    expect(response).to have_http_status(:bad_request)
                    response_body = JSON.parse(response.body)
                    expect(response_body["errors"]).to include("Code challenge method can't be blank", "Code challenge method is not included in the list")
                end
            end
            context "when client_id is invalid" do
                it "returns error" do
                    params = valid_params.merge(client_id: "invalid_client")
                    get :authorize, params: params

                    expect(response).to have_http_status(:bad_request)
                    response_body = JSON.parse(response.body)
                    expect(response_body["errors"]).to include("Client is invalid")
                end
            end
            context "creates authorization code with correct attributes" do
                it "creates authorization code" do
                    expect {
                        get :redirect_to_client, params: valid_params.merge(client_config_id: client_config.id)
                    }.to change(Oauth::AuthorizationCode, :count).by(1)

                    auth_code = Oauth::AuthorizationCode.last
                    expect(auth_code.user_id).to eq(user.id)
                    expect(auth_code.client_config_id).to eq(client_config.id)
                    expect(auth_code.code_challenge).to eq("code_challenge_12345")
                end
            end
            context "it deletes session[:oauth_params] after redirect_to_client" do
                it "deletes session[:oauth_params]" do
                    get :redirect_to_client, params: valid_params.merge(client_config_id: client_config.id)

                    expect(session[:oauth_params]).to be_nil
                end
            end
        end
    end
end
