require "rails_helper"

RSpec.describe OauthController, type: :controller do
    describe "GET #authorize" do
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
        context "when all params are valid" do
            it "returns success response" do
                get :authorize, params: valid_params
                expect(response).to have_http_status(:success)
                expect(JSON.parse(response.body)).to eq({
                    "success" => true,
                    "message" => "Params are valid"
                })
            end
        end
        context 'with invalid params' do
            context "when response_type is invalid" do
                it "returns error" do
                    params = valid_params.except(:response_type)
                    get :authorize, params: params

                    expect(response).to have_http_status(:bad_request)
                    response_body = JSON.parse(response.body)
                    expect(response_body["errors"]).to include("response_type must be code")
                end
            end

            context "when client_id is missing" do
                it "returns error" do
                    params = valid_params.except(:client_id)
                    get :authorize, params: params

                    expect(response).to have_http_status(:bad_request)
                    response_body = JSON.parse(response.body)
                    expect(response_body["errors"]).to include("client_id is required")
                end
            end
            context "when redirect_uri is missing" do
                it "returns error" do
                    params = valid_params.except(:redirect_uri)
                    get :authorize, params: params

                    expect(response).to have_http_status(:bad_request)
                    response_body = JSON.parse(response.body)
                    expect(response_body["errors"]).to include("redirect_uri is required")
                end
            end
            context "when scope is missing" do
                it "returns error" do
                    params = valid_params.except(:scope)
                    get :authorize, params: params

                    expect(response).to have_http_status(:bad_request)
                    response_body = JSON.parse(response.body)
                    expect(response_body["errors"]).to include("scope is required")
                end
            end
            context "when state is missing" do
                it "returns error" do
                    params = valid_params.except(:state)
                    get :authorize, params: params

                    expect(response).to have_http_status(:bad_request)
                    response_body = JSON.parse(response.body)
                    expect(response_body["errors"]).to include("state is required")
                end
            end
            context "when code_challenge is missing" do
                it "returns error" do
                    params = valid_params.except(:code_challenge)
                    get :authorize, params: params

                    expect(response).to have_http_status(:bad_request)
                    response_body = JSON.parse(response.body)
                    expect(response_body["errors"]).to include("code_challenge is required")
                end
            end
            context "when code_challenge_method is missing" do
                it "returns error" do
                    params = valid_params.except(:code_challenge_method)
                    get :authorize, params: params

                    expect(response).to have_http_status(:bad_request)
                    response_body = JSON.parse(response.body)
                    expect(response_body["errors"]).to include("code_challenge_method must be S256")
                end
            end
        end
        context 'session storage' do
            context 'does not store params in session if validation fails' do
                it 'returns error' do
                    params = valid_params.except(:client_id)
                    get :authorize, params: params

                    expect(session[:oauth_params]). to be_nil
                end
            end
            context 'stores params in session if validation passes' do
                it 'returns success' do
                get :authorize, params: valid_params

                expect(session[:oauth_params][:client_id]).to eq(valid_params[:client_id])
                expect(session[:oauth_params][:redirect_uri]).to eq(valid_params[:redirect_uri])
                expect(session[:oauth_params][:state]).to eq(valid_params[:state])
                expect(session[:oauth_params][:code_challenge]).to eq(valid_params[:code_challenge])
                expect(session[:oauth_params][:scope]).to eq(valid_params[:scope])
                end
            end
        end
    end
end
