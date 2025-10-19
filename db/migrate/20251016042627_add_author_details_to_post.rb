class AddAuthorDetailsToPost < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :author_url, :string
    add_column :posts, :author_bio, :text
    add_column :posts, :author_social_url, :string
  end
end
