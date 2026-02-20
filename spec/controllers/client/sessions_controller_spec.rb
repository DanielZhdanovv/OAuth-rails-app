require "rails_helper"

RSpec.describe Client::SessionsController, type: :controller do
    include Devise::Test::ControllerHelpers
    let(:user) { Oauth::User.create!(first_name: 'Adam', last_name: 'Smith', email: 'test@example.com', password: 'password12345') }
    let(:valid_state) { SecureRandom.hex(16) }
    let(:invalid_state) { SecureRandom.hex(16) }
    describe 'Client app' do
        context 'GET #login' do
            context 'generates code_verifier' do
                it 'stores code_verifier in session' do
                    get :login
                    expect(session[:client][:code_verifier]).to be_present
                    expect(session[:client][:code_verifier].length).to eq(43)
                end
            end
            context 'generates state' do
                it 'stores state in session' do
                    get :login
                    expect(session[:client][:state]).to be_present
                    expect(session[:client][:state].length).to eq(32)
                end
            end
            context '#login redirects to server endpoint' do
                it 'builds required params' do
                    get :login

                    redirect_url = response.location
                    expect(redirect_url).to include('response_type=code')
                    expect(redirect_url).to include('client_id=client_app_123')
                    expect(redirect_url).to include("state=#{session[:client][:state]}")
                    expect(redirect_url).to include('code_challenge')
                    expect(redirect_url).to include('code_challenge_method')
                end
            end
        end
        context '#callback' do
            context 'with valid state' do
                it 'returns success' do
                    session[:client] = {}
                    session[:client]["state"] = valid_state

                    get :callback, params: { code: 'test_code_1234', state: valid_state }
                    expect(response).to have_http_status(:ok)
                end
            end
            context 'with invalid state' do
                it 'returns error' do
                    session[:client] = {}
                    session[:client][:state] = valid_state

                    get :callback, params: { code: 'test_code_1234', state: invalid_state }
                    expect(JSON.parse(response.body)).to eq({ 'error'=>'Invalid state' })
                end
            end
        end
        context 'GET #user_registration' do
            it 'redirects to devise registration page' do
                get :user_registration
                expect(response).to redirect_to(new_user_registration_path)
            end
        end
        context 'GET #logout' do
            it 'redirects to devise registration page' do
                sign_in(user, scope: :user)
                session[:client] = {}
                session[:client][:code_verifier] = 'test_verifier'
                session[:client][:state] = 'state'

                expect(controller).to receive(:sign_out).with(:user)
                delete :logout
                session[:client] = {}
                expect(session[:client][:code_verifier]).to be_nil
                expect(session[:client][:state]).to be_nil
                expect(response).to redirect_to(client_root_path)
            end
        end
    end
end
