require "rails_helper"

RSpec.describe Server::User, type: :model do
  subject(:user) do
    Server::User.new(
      first_name: first_name,
      last_name: last_name,
      email: email,
      password: password
    )
  end
  let(:valid_token) do
    payload = { user_id: user.id, exp: 1.hour.from_now.to_i }
    JWT.encode(payload, Rails.application.credentials.secret_key_base, "HS256")
  end
  let(:expired_token) do
    payload = { user_id: user.id, exp: 1.hour.ago.to_i }
    JWT.encode(payload, Rails.application.credentials.secret_key_base, "HS256")
  end

  let(:first_name) { 'Firstname' }
  let(:last_name)  { 'Lastname' }
  let(:email)      { 'test@example.com' }
  let(:password)   { 'password123' }

  describe 'user validations' do
    context 'with valid attributes' do
      it 'is valid' do
        expect(user).to be_valid
      end
    end
    context 'with invalid params' do
      context 'when first_name is missing' do
        let(:first_name) { nil }
        it 'is not valid' do
          expect(user).not_to be_valid
        end
      end
      context 'when last_name is missing' do
        let(:last_name) { nil }
        it 'is not valid' do
          expect(user).not_to be_valid
        end
      end
      context 'when email is missing' do
        let(:email) { nil }
        it 'is not valid' do
          expect(user).not_to be_valid
        end
      end
      context 'password does not meet length requirement' do
        let(:password) { '123' }
        it 'is not valid' do
          expect(user).not_to be_valid
        end
      end
    end
  end
  describe 'GET #show' do
    context 'with valid token' do
      it 'returns user details' do
        user.save!
        decoded_token = JWT.decode(valid_token, Rails.application.credentials.secret_key_base, true, algorithm: "HS256")
        user_id = decoded_token[0]["user_id"]
        expect(user_id).to eq(user.id)
        expect(user.first_name).to eq(first_name)
        expect(user.last_name).to eq(last_name)
        expect(user.email).to eq(email)
      end
    end
    context 'with expired token' do
      it 'raises JWT::ExpiredSignature error' do
        user.save!
        expect {
          JWT.decode(expired_token, Rails.application.credentials.secret_key_base, true, algorithm: "HS256")
        }.to raise_error(JWT::ExpiredSignature)
      end
    end
  end
end
