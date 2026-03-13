# frozen_string_literal: true

module Oauth
  # The ClientConfig model represents the configuration for an OAuth client
  class ClientConfig < ApplicationRecord
    validates :name, presence: true
    validates :client_id, presence: true, uniqueness: true
    validates :redirect_uri, presence: true
  end
end
