class AddEmailOtpToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :email_otp_code, :string
    add_column :users, :email_otp_expires_at, :datetime
  end
end
