# frozen_string_literal: true

# This migration creates the refresh_tokens table with the necessary columns and indexes
class RefreshTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :refresh_tokens do |t|
      t.string   :token
      t.references :user, foreign_key: true
      t.references :client_config, null: false, foreign_key: true
      t.datetime :expires_at, null: false
      t.string :jti, null: false
      t.datetime :revoked_at

      t.timestamps null: false
    end
    add_index :refresh_tokens, :token, unique: true
    add_index :refresh_tokens, :jti, unique: true
  end
end
