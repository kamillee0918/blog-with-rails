class RemoveTagsStringFromPosts < ActiveRecord::Migration[8.1]
  def change
    remove_column :posts, :tags, :string
  end
end
