class CreateTagsAndPostsTags < ActiveRecord::Migration[8.1]
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.timestamps
    end
    add_index :tags, :name, unique: true

    create_table :posts_tags, id: false do |t|
      t.belongs_to :post, null: false, foreign_key: true
      t.belongs_to :tag, null: false, foreign_key: true
    end
    add_index :posts_tags, [ :post_id, :tag_id ], unique: true
  end
end
