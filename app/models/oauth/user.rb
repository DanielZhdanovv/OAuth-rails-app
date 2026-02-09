module Oauth
  class User < ApplicationRecord
    self.table_name = "users"
    devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :validatable, :trackable

    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :email, presence: true, uniqueness: true
  end
end
