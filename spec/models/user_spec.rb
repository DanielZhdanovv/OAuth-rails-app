require "rails_helper"

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'validates presence of a first_name' do
      user = User.new(first_name: nil, last_name: 'Lastname', email: 'test@example.com', password: 'password12345')
      expect(user.valid?).to be false
      expect(user.errors[:first_name]).to include("can't be blank")
    end

    it 'validates presence of last_name' do
      user = User.new(first_name: "Firstname", last_name: nil, email: 'test@example.com', password: 'password12345')
      expect(user.valid?).to be false
      expect(user.errors[:last_name]).to include("can't be blank")
    end

    it 'validates presence of email' do
      user = User.new(first_name: 'Firstname', last_name: 'Lastname', email: nil, password: 'password12345')
      expect(user.valid?).to be false
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'validates password length' do
      user = User.new(first_name: 'Firstname', last_name: 'Lastname', email: 'test@example.com', password: '123')
      expect(user.valid?).to be false
      expect(user.errors[:password]).to include('is too short (minimum is 6 characters)')
    end
  end
end
