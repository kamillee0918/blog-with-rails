class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :magic_link_token, null: false
      t.datetime :magic_link_sent_at

      t.boolean :verified, null: false, default: false

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :magic_link_token, unique: true
  end
end
