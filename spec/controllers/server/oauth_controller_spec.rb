# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Server::OauthController, type: :controller do # rubocop:disable Metrics/BlockLength
  include Devise::Test::ControllerHelpers

  let(:user) { Server::User.create!(first_name: 'Adam', last_name: 'Smith', email: 'test@example.com', password: 'password12345') }
  let(:client_config) { Oauth::ClientConfig.create!(name: 'Test Client', client_id: 'test_client', redirect_uri: 'http://localhost:3000') }

  before do
    new_server_user_session_path
    sign_in(user, scope: :user)
    allow(controller).to receive(:current_server_user).and_return(user)
  end
  describe 'GET #authorize' do # rubocop:disable Metrics/BlockLength
    let(:valid_params) do
      {
        response_type: 'code',
        client_id: 'test_client',
        state: 'state1',
        code_challenge: 'code_challenge_12345',
        code_challenge_method: 'S256'
      }
    end
    context 'with valid params' do
      context 'in authorize' do
        it 'redirects to user login page' do
          get :authorize, params: valid_params.merge(client_config_id: client_config.id)
          expect(response).to redirect_to(new_server_user_session_path)
        end
      end
    end
    context 'with invalid params' do # rubocop:disable Metrics/BlockLength
      context 'when response_type is invalid' do
        it 'returns error' do
          params = valid_params.except(:response_type)
          get :authorize, params: params

          expect(response).to have_http_status(:bad_request)
          response_body = response.parsed_body
          expect(response_body['errors']).to include("Response type can't be blank",
                                                     'Response type is not included in the list')
        end
      end

      context 'when client_id is missing' do
        it 'returns error' do
          params = valid_params.except(:client_id)
          get :authorize, params: params

          expect(response).to have_http_status(:bad_request)
          response_body = response.parsed_body
          expect(response_body['errors']).to include("Client can't be blank")
        end
      end
      context 'when state is missing' do
        it 'returns error' do
          params = valid_params.except(:state)
          get :authorize, params: params

          expect(response).to have_http_status(:bad_request)
          response_body = response.parsed_body
          expect(response_body['errors']).to include("State can't be blank")
        end
      end
      context 'when code_challenge is missing' do
        it 'returns error' do
          params = valid_params.except(:code_challenge)
          get :authorize, params: params

          expect(response).to have_http_status(:bad_request)
          response_body = response.parsed_body
          expect(response_body['errors']).to include("Code challenge can't be blank")
        end
      end
      context 'when code_challenge_method is missing' do
        it 'returns error' do
          params = valid_params.except(:code_challenge_method)
          get :authorize, params: params

          expect(response).to have_http_status(:bad_request)
          response_body = response.parsed_body
          expect(response_body['errors']).to include("Code challenge method can't be blank",
                                                     'Code challenge method is not included in the list')
        end
      end
      context 'when client_id is invalid' do
        it 'returns error' do
          params = valid_params.merge(client_id: 'invalid_client')
          get :authorize, params: params

          expect(response).to have_http_status(:bad_request)
          response_body = response.parsed_body
          expect(response_body['errors']).to include('Client is invalid')
        end
      end
      context 'creates authorization code with correct attributes' do
        it 'creates authorization code' do
          session[:oauth_params] =
            valid_params.merge('client_config_id' => client_config.id, 'code_challenge' => 'code_challenge_12345',
                               'redirect_uri' => client_config.redirect_uri)
          expect do
            get :after_login
          end.to change(Oauth::AuthorizationCode, :count).by(1)

          auth_code = Oauth::AuthorizationCode.last
          expect(auth_code.user_id).to eq(user.id)
          expect(auth_code.client_config_id).to eq(client_config.id)
          expect(auth_code.code_challenge).to eq('code_challenge_12345')
        end
      end
      context 'it deletes session[:oauth_params] after callback' do
        it 'deletes session[:oauth_params]' do
          session[:oauth_params] =
            valid_params.merge('client_config_id' => client_config.id, 'code_challenge' => 'code_challenge_12345',
                               'redirect_uri' => client_config.redirect_uri)

          get :after_login, params: session[:oauth_params]
          expect(session[:oauth_params]).to be_nil
        end
      end
    end
  end
  describe 'POST #token' do # rubocop:disable Metrics/BlockLength
    let(:auth_code) do
      Oauth::AuthorizationCode.create!(
        code: 'oauth_code',
        user: user,
        client_config: client_config,
        code_challenge: '9J5ble84bN5lfh6OKo8YIl_BxIGMBEBKCEpBpH8swdg'
      )
    end
    let(:refresh_token) do
      Oauth::RefreshToken.create!(
        token: 'refresh_token_1234',
        user: user,
        client_config: client_config,
        expires_at: 15.minutes.from_now,
        jti: SecureRandom.uuid
      )
    end
    describe 'handle_authorization_code' do # rubocop:disable Metrics/BlockLength
      let(:valid_auth_code_params) do
        {
          grant_type: 'authorization_code',
          code: auth_code.code,
          client_id: client_config.client_id,
          code_verifier: 'code_verifier_123'
        }
      end
      let(:params) { valid_auth_code_params }
      subject { post :token, params: }
      context 'with valid params' do
        context 'in handle_authorization_code' do
          it 'return access_token and refresh_token' do
            subject
            expect(response).to have_http_status(:success)
            response_body = response.parsed_body
            expect(response_body['access_token']).to be_present
            expect(response_body['token_type']).to eq('Bearer')
            expect(response_body['expires_in']).to eq(900)
            expect(response_body['refresh_token']).to be_present
          end
        end
      end
      context 'with invalid params' do # rubocop:disable Metrics/BlockLength
        context 'when auth code is missing' do
          let(:params) { valid_auth_code_params.except(:code) }
          it 'returns error' do
            subject

            expect(response).to have_http_status(400)
            response_body = response.parsed_body
            expect(response_body['errors']).to eq(["Code can't be blank"])
          end
        end
        context 'when auth code is invalid' do
          let(:params) { valid_auth_code_params.merge(code: 'invalid_code') }
          it 'returns error' do
            subject
            expect(response).to have_http_status(400)
          end
        end
        context 'when client_id is invalid' do
          let(:params) { valid_auth_code_params.merge(client_id: 'invalid_client') }
          it 'returns error' do
            subject
            expect(response).to have_http_status(400)
          end
        end
        context 'when code verifier is missing' do
          let(:params) { valid_auth_code_params.except(:code_verifier) }
          it 'returns error' do
            subject
            expect(response).to have_http_status(400)
            response_body = response.parsed_body
            expect(response_body['errors']).to eq(["Code verifier can't be blank"])
          end
        end
        context 'PKCE verification fails' do
          let(:params) { valid_auth_code_params.merge(code_verifier: 'invalid_code_verifier') }
          it 'returns error' do
            subject
            expect(response).to have_http_status(:bad_request)
            response_body = response.parsed_body
            expect(response_body['error']).to eq('Failed PKCE verification')
          end
        end
      end
    end
    describe 'handle_refresh_code' do # rubocop:disable Metrics/BlockLength
      let(:valid_refresh_token_params) do
        {
          grant_type: 'refresh_token',
          client_id: client_config.client_id,
          refresh_token: refresh_token.token
        }
      end

      let(:params) { valid_refresh_token_params }
      subject { post :token, params: }

      context 'with grant_type refresh_code' do
        it 'returns new_access token and refresh_token' do
          subject
          expect(response).to have_http_status(:success)
          response_body = response.parsed_body
          expect(response_body['access_token']).to be_present
          expect(response_body['token_type']).to eq('Bearer')
          expect(response_body['expires_in']).to eq(900)
          expect(response_body['refresh_token']).to be_present
          expect(response_body['refresh_token']).not_to eq(refresh_token.token)
        end
      end
      context 'refreshing token' do
        it 'revokes old refresh token' do
          expect(refresh_token.revoked_at).to be_nil
          subject
          old_refresh_token = refresh_token.reload
          expect(old_refresh_token.revoked_at).to be_present
        end
      end
      context 'refresh token is missing' do
        let(:params) { valid_refresh_token_params.except(:refresh_token) }
        it 'returns error' do
          subject
          response_body = response.parsed_body
          expect(response_body['errors']).to eq(["Refresh token can't be blank"])
        end
      end
      context 'refresh token is invalid' do
        let(:params) { valid_refresh_token_params.merge(refresh_token: 'invalid_token') }
        it 'returns error' do
          subject
          response_body = response.parsed_body
          expect(response_body['errors']).to eq(['Refresh token not found'])
        end
      end
      context 'client is invalid' do
        let(:params) { valid_refresh_token_params.merge(client_id: 'invalid_client') }
        it 'returns error' do
          subject
          response_body = response.parsed_body
          expect(response_body['errors']).to eq(['Client is invalid'])
        end
      end
      context 'refresh_token is revoked' do
        it 'returns error' do
          refresh_token.revoke!
          subject
          response_body = response.parsed_body
          expect(response_body['errors']).to eq(['Refresh token has been revoked'])
        end
      end
      context 'refresh_token is expired' do
        it 'returns error' do
          refresh_token.update!(expires_at: 2.days.ago)
          subject
          response_body = response.parsed_body
          expect(response_body['errors']).to eq(['Refresh token has been expired'])
        end
      end
    end
  end
end
