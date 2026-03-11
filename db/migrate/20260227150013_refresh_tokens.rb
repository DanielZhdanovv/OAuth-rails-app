class RefreshTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :refresh_tokens do |t|
      t.string   :token
      t.references :user
      t.references :client_config, null: false, foreign_key: true
      t.datetime :expires_at, null: false
      t.string :jti, null: false
      t.datetime :revoked_at

      t.timestamps null: false
    end
  end
end
