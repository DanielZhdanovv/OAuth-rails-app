# frozen_string_literal: true

# This migration creates the client_configs table with the necessary columns and timestamps
class ClientConfig < ActiveRecord::Migration[8.1]
  def change
    create_table :client_configs do |t|
      t.string   :name
      t.string   :client_id
      t.string   :redirect_uri

      t.timestamps null: false
    end
  end
end
