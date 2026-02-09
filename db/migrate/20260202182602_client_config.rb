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
