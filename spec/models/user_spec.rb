require "rails_helper"

RSpec.describe User, type: :model do
  subject(:user) do
    User.new(
      first_name: first_name,
      last_name: last_name,
      email: email,
      password: password
    )
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
