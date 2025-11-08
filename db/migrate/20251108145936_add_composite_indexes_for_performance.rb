class AddCompositeIndexesForPerformance < ActiveRecord::Migration[8.0]
  def change
    # Newsletter subscribers 쿼리 최적화
    # User.where(verified: true, enable_newsletter_notifications: true)
    #     .where(deleted_at: nil)
    add_index :users,
              [ :verified, :enable_newsletter_notifications, :deleted_at ],
              name: "index_users_on_newsletter_scope"

    # Featured posts 쿼리 최적화
    # Post.where.not(published_at: nil).where(featured: true)
    add_index :posts,
              [ :published_at, :featured ],
              name: "index_posts_on_published_featured"
  end
end
