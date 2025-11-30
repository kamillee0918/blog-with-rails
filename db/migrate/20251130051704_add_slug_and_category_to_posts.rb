class AddSlugAndCategoryToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :slug, :string
    add_index :posts, :slug, unique: true
    add_column :posts, :category, :string
    add_index :posts, :category
  end
end
