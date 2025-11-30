# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Cleaning up existing posts..."
Post.destroy_all

puts "Creating seed posts..."

titles = [
  "Scaling Rails to 100k Requests per Second",
  "How We Migrated from Microservices Back to Monolith",
  "Optimizing Database Queries for High Performance",
  "The Future of Frontend Development at Our Company",
  "Building a Resilient Distributed System",
  "Our Journey to Cloud Native Architecture",
  "Improving Developer Productivity with Custom Tools",
  "Deep Dive into Ruby Memory Management",
  "Securing Your Rails Application Against Modern Threats",
  "Why We Chose Hotwire for Our New Project",
  "Understanding Concurrency in Ruby 3",
  "GraphQL vs REST: A Practical Comparison",
  "Implementing Real-time Features with ActionCable",
  "CI/CD Best Practices for Rails Applications",
  "Managing Technical Debt in Growing Codebases",
  "Introduction to Solid Queue for Background Jobs",
  "Building APIs with Rails 8 and JSON:API",
  "Effective Testing Strategies for Rails Apps",
  "Deploying Rails with Kamal 2",
  "PostgreSQL Performance Tips for Rails Developers"
]

tags_list = [
  "rails, performance, scaling, infrastructure",
  "architecture, microservices, monolith",
  "database, activerecord, sql, optimization",
  "frontend, react, javascript, ux",
  "distributed-systems, resilience, reliability",
  "cloud, kubernetes, docker, devops",
  "developer-experience, tools, productivity",
  "ruby, memory, debugging, performance",
  "security, authentication, rails",
  "hotwire, turbo, stimulus, rails",
  "ruby, concurrency, ractor, fiber",
  "api, graphql, rest, design",
  "websockets, actioncable, realtime",
  "ci, cd, github-actions, deployment",
  "refactoring, technical-debt, code-quality",
  "background-jobs, solid-queue, async",
  "api, rails, json-api, serialization",
  "testing, rspec, minitest, tdd",
  "deployment, kamal, docker, production",
  "postgresql, database, performance, indexing"
]

summaries = [
  "Learn how we scaled our Rails application to handle massive traffic with careful optimization and infrastructure tuning.",
  "Discover the reasons behind our architectural shift and the benefits we've seen since returning to a monolith.",
  "A technical deep dive into ActiveRecord optimizations and SQL tuning techniques.",
  "We're adopting new frontend technologies to improve user experience and developer velocity.",
  "Strategies and patterns we use to ensure our systems stay up even when parts fail.",
  "How we containerized our applications and orchestrated them with Kubernetes.",
  "An overview of the internal tools we've built to streamline our development workflow.",
  "Understanding how Ruby handles memory and how to debug memory leaks in production.",
  "Best practices for protecting your application data and user privacy.",
  "A case study on using Hotwire to build responsive SPAs without writing complex JavaScript.",
  "Exploring Ruby 3's new concurrency features including Ractors and Fiber Scheduler.",
  "When to use GraphQL and when REST is the better choice for your API needs.",
  "Building interactive real-time features using Rails ActionCable and WebSockets.",
  "Setting up robust continuous integration and deployment pipelines for Rails projects.",
  "Strategies for identifying, prioritizing, and paying down technical debt effectively.",
  "Getting started with Solid Queue, Rails' new default background job processor.",
  "Building clean, well-documented APIs following the JSON:API specification.",
  "Writing maintainable tests that give you confidence without slowing you down.",
  "A complete guide to deploying Rails applications with Kamal 2.",
  "Advanced PostgreSQL techniques to boost your Rails application performance."
]

categories = [
  "Engineering",
  "Architecture",
  "Database",
  "Frontend",
  "Infrastructure",
  "DevOps",
  "Productivity",
  "Ruby",
  "Security",
  "Rails",
  "Ruby",
  "API",
  "Rails",
  "DevOps",
  "Engineering",
  "Rails",
  "API",
  "Testing",
  "DevOps",
  "Database"
]

credits = [
  "Gumbel AlphaZero",
  "Computer Science",
  "Dummy Credit"
]

20.times do |i|
  post = Post.create!(
    title: titles[i],
    summary: summaries[i],
    author: "Kamil Lee",
    tags: tags_list[i],
    category: categories[i],
    content: "<p>This is the main content for <strong>#{titles[i]}</strong>.</p><p>#{summaries[i]}</p><p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.</p>",
    published_at: Time.current - i.days
  )

  # Attach cover image
  image_files = [ "gumbel_alphazero_thumbnail.png", "cpu_scheduler_thumbnail.png", "dummy_thumbnail.png" ]
  image_file = image_files[i % image_files.length]
  image_path = Rails.root.join("app/assets/images/thumbnail", image_file)
  caption = credits[i % credits.length]

  if File.exist?(image_path)
    post.cover_image.attach(
      io: File.open(image_path),
      filename: image_file,
      content_type: "image/png",
      metadata: { credit: caption }
    )
    puts "  Attached #{image_file} to '#{titles[i]}'"
  else
    puts "  Could not find image: #{image_path}"
  end
end

puts "Created #{Post.count} posts."
