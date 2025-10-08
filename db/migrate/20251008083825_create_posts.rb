class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.string :title
      t.string :slug
      t.text :content
      t.text :excerpt
      t.string :category
      t.string :author_name
      t.string :author_avatar
      t.datetime :published_at
      t.boolean :featured
      t.string :featured_image
      t.string :image_caption

      t.timestamps
    end
  end
end
