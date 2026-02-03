class AuthorizationCode < ActiveRecord::Migration[8.1]
  def change
    create_table :authorization_code do |t|
      t.string   :code
      t.string   :code_challenge
      t.references :user, null: false, foreign_key: true
      t.references :client_config, null: false, foreign_key: true

      t.timestamps null: false
    end
  end
end
