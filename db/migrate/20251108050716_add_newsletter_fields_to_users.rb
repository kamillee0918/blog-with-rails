class AddNewsletterFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :enable_newsletter_notifications, :boolean, default: false, null: false
    add_column :users, :deleted_at, :datetime
    add_index :users, :deleted_at
  end
end
