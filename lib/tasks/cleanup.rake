# frozen_string_literal: true

namespace :cleanup do
  desc "Delete unverified users older than 24 hours"
  task unverified_users: :environment do
    cutoff_time = 24.hours.ago

    unverified_users = User.where(verified: false)
                           .where("created_at < ?", cutoff_time)

    count = unverified_users.count

    if count > 0
      deleted_emails = unverified_users.pluck(:email)
      unverified_users.destroy_all

      puts "=" * 81
      puts "🗑️  Cleanup: Deleted #{count} unverified user(s)"
      puts "=" * 81
      puts "Emails: #{deleted_emails.join(', ')}"
      puts "=" * 81

      Rails.logger.info "Cleanup: Deleted #{count} unverified users older than 24 hours"
    else
      puts "✅ No unverified users to clean up"
    end
  end

  desc "Delete expired sessions older than 30 days"
  task expired_sessions: :environment do
    cutoff_time = 30.days.ago

    expired_sessions = Session.where("created_at < ?", cutoff_time)
    count = expired_sessions.count

    if count > 0
      expired_sessions.destroy_all

      puts "=" * 81
      puts "🗑️  Cleanup: Deleted #{count} expired session(s)"
      puts "=" * 81

      Rails.logger.info "Cleanup: Deleted #{count} expired sessions older than 30 days"
    else
      puts "✅ No expired sessions to clean up"
    end
  end

  desc "Run all cleanup tasks"
  task all: :environment do
    puts "\n🧹 Starting cleanup tasks...\n\n"
    Rake::Task["cleanup:unverified_users"].invoke
    Rake::Task["cleanup:expired_sessions"].invoke
    puts "\n✅ All cleanup tasks completed!\n"
  end
end
