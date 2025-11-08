class FixUsersTableForMagicLink < ActiveRecord::Migration[8.0]
  def up
    # password_digest 컬럼 제거
    if column_exists?(:users, :password_digest)
      remove_column :users, :password_digest
    end

    # magic_link_token 컬럼 추가
    unless column_exists?(:users, :magic_link_token)
      add_column :users, :magic_link_token, :string

      # 기존 사용자에게 임시 토큰 생성
      User.reset_column_information
      User.find_each do |user|
        user.update_column(:magic_link_token, SecureRandom.urlsafe_base64(27))
      end

      # null: false 제약 추가
      change_column_null :users, :magic_link_token, false
      add_index :users, :magic_link_token, unique: true
    end

    # magic_link_sent_at 컬럼 추가
    unless column_exists?(:users, :magic_link_sent_at)
      add_column :users, :magic_link_sent_at, :datetime
    end
  end

  def down
    # Rollback 로직
    remove_column :users, :magic_link_sent_at if column_exists?(:users, :magic_link_sent_at)
    remove_index :users, :magic_link_token if index_exists?(:users, :magic_link_token)
    remove_column :users, :magic_link_token if column_exists?(:users, :magic_link_token)
    add_column :users, :password_digest, :string, null: false unless column_exists?(:users, :password_digest)
  end
end
