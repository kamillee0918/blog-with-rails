class AddIndexesAndConstraintsToPosts < ActiveRecord::Migration[8.0]
  def change
    # Add NOT NULL constraints
    change_column_null :posts, :title, false
    change_column_null :posts, :slug, false

    # Set default value for featured
    change_column_default :posts, :featured, false

    # Add indexes for performance
    add_index :posts, :slug, unique: true
    add_index :posts, :published_at
    add_index :posts, :category
    add_index :posts, :featured
  end
end
