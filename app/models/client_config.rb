class ClientConfig < ApplicationRecord
    validates :name, presence: true
    validates :client_id, presence: true, uniqueness: true
    validates :redirect_uri, presence: true
end
