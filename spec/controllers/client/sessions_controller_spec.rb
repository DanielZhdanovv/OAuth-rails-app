require "rails_helper"

RSpec.describe Client::SessionsController, type: :controller do
    include Devise::Test::ControllerHelpers
    let(:user) { Server::User.create!(first_name: 'Adam', last_name: 'Smith', email: 'test@example.com', password: 'password12345') }
    let(:valid_state) { SecureRandom.hex(16) }
    let(:invalid_state) { SecureRandom.hex(16) }

    describe 'GET #login' do
        subject { get :login }
        context 'generates code_verifier and state' do
            it 'stores code_verifier and state in session' do
                subject
                expect(session[:client][:code_verifier]).to be_present
                expect(session[:client][:code_verifier].length).to eq(43)
                expect(session[:client][:state]).to be_present
                expect(session[:client][:state].length).to eq(32)
            end
        end
        context 'redirects to server endpoint' do
            it 'builds required params' do
                subject

                redirect_url = response.location
                expect(redirect_url).to include('response_type=code')
                expect(redirect_url).to include('client_id=client_app_123')
                expect(redirect_url).to include("state=#{session[:client][:state]}")
                expect(redirect_url).to include('code_challenge')
                expect(redirect_url).to include('code_challenge_method')
            end
        end
    end
    describe 'GET #callback' do
        let(:params) { { code:, state: } }
        let(:code) { 'test_code_1234' }
        let(:state) { valid_state }

        subject { get :callback, params: }

        context 'with valid state' do
            before do
                session[:client] = {}
                session[:client]["state"] = valid_state
            end

            it 'returns success' do
                subject
                expect(response).to have_http_status(:ok)
            end
        end
        context 'with invalid state' do
            before do
                session[:client] = {}
                session[:client]["state"] = invalid_state
            end

            it 'returns error' do
                subject
                expect(JSON.parse(response.body)).to eq({ 'error'=>'Invalid state' })
            end
        end
    end
        context 'GET #user_registration' do
            it 'redirects to devise registration page' do
                get :user_registration
                expect(response).to redirect_to(new_server_user_registration_path)
            end
        end
    describe 'GET #logout' do
        subject { get :logout }
        context 'after logout' do
            it 'redirects to devise registration page' do
                sign_in(user, scope: :user)
                session[:client] = {}
                session[:client][:code_verifier] = 'test_verifier'
                session[:client][:state] = 'state'

                subject
                session[:client] = {}
                expect(session[:client][:code_verifier]).to be_nil
                expect(session[:client][:state]).to be_nil
                expect(response).to redirect_to(client_root_path)
            end
        end
    end
end
