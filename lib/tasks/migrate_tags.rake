# === Production Tag Migration ===
#
# Run BEFORE the RemoveTagsStringFromPosts migration:
#   1. bundle exec rails db:migrate (up to CreateTagsAndPostsTags)
#   2. bundle exec rails tags:migrate
#   3. bundle exec rails tags:verify
#   4. bundle exec rails db:migrate (RemoveTagsStringFromPosts)
#
namespace :tags do
  desc "Migrate comma-separated tags string to normalized Tag records"
  task migrate: :environment do
    unless ActiveRecord::Base.connection.column_exists?(:posts, :tags)
      abort "ERROR: posts.tags column not found. This task must run BEFORE RemoveTagsStringFromPosts migration."
    end

    puts "Starting tag migration..."

    migrated = 0
    skipped = 0

    Post.where("tags IS NOT NULL AND tags != ''").find_each do |post|
      tag_names = post.read_attribute(:tags).split(",").map(&:strip).reject(&:blank?).map(&:downcase).uniq

      tag_names.each do |name|
        tag = Tag.find_or_create_by!(name: name)
        unless post.tags.exists?(tag.id)
          post.tags << tag
        end
      end

      migrated += 1
    rescue => e
      puts "  ERROR on Post##{post.id} (#{post.title}): #{e.message}"
      skipped += 1
    end

    puts "Done! Migrated: #{migrated}, Skipped: #{skipped}"
    puts "Total tags: #{Tag.count}, Total associations: #{ActiveRecord::Base.connection.select_value('SELECT COUNT(*) FROM posts_tags')}"
  end

  desc "Verify tag migration completeness"
  task verify: :environment do
    unless ActiveRecord::Base.connection.column_exists?(:posts, :tags)
      abort "ERROR: posts.tags column not found. This task must run BEFORE RemoveTagsStringFromPosts migration."
    end

    puts "Verifying tag migration..."

    issues = 0
    Post.where("tags IS NOT NULL AND tags != ''").find_each do |post|
      old_tags = post.read_attribute(:tags).split(",").map(&:strip).reject(&:blank?).map(&:downcase).uniq
      new_tags = post.tags.pluck(:name).sort

      missing = old_tags.sort - new_tags
      if missing.any?
        puts "  Post##{post.id} (#{post.title}): missing tags: #{missing.join(', ')}"
        issues += 1
      end
    end

    if issues == 0
      puts "All tags migrated successfully!"
    else
      puts "#{issues} post(s) have missing tags."
    end
  end
end
