# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Cleaning up existing posts..."
Post.destroy_all

puts "Creating seed posts..."

10.times do |i|
  title = [
    "Scaling Rails to 100k Requests per Second",
    "How We Migrated from Microservices Back to Monolith",
    "Optimizing Database Queries for High Performance",
    "The Future of Frontend Development at Our Company",
    "Building a Resilient Distributed System",
    "Our Journey to Cloud Native Architecture",
    "Improving Developer Productivity with Custom Tools",
    "Deep Dive into Ruby Memory Management",
    "Securing Your Rails Application Against Modern Threats",
    "Why We Chose Hotwire for Our New Project"
  ][i]

  tags = [
    "rails, performance, scaling, infrastructure",
    "architecture, microservices, monolith",
    "database, activerecord, sql, optimization",
    "frontend, react, javascript, ux",
    "distributed-systems, resilience, reliability",
    "cloud, kubernetes, docker, devops",
    "developer-experience, tools, productivity",
    "ruby, memory, debugging, performance",
    "security, authentication, rails",
    "hotwire, turbo, stimulus, rails"
  ][i]

  summary = [
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc accumsan odio dolor, eu iaculis ex semper pretium. Phasellus in consectetur lorem. Nam feugiat sollicitudin risus quis cursus. Mauris mi nisi, venenatis in bibendum eleifend, aliquet nec nulla. Aenean sollicitudin, justo eget faucibus scelerisque, eros tortor luctus orci, a faucibus odio diam in orci. Integer dictum scelerisque ante, a accumsan leo efficitur efficitur. Maecenas pharetra pretium sapien non tempus. Phasellus ex massa, facilisis consectetur dui eget, condimentum semper ex. Aliquam aliquam felis sit amet diam congue, vel tristique lectus interdum. Nam pretium molestie leo at aliquet. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec nec molestie risus. Sed ipsum magna, cursus id venenatis at, ullamcorper at eros. Phasellus id tellus dui. Fusce sit amet iaculis massa. Aenean non porttitor risus. Maecenas et diam nulla. Aliquam ac erat dolor. Nunc vitae venenatis elit. In eget justo nulla. Quisque lacinia bibendum nulla, ac efficitur justo elementum eget. Quisque ornare, massa vitae gravida interdum, velit neque dictum felis, at feugiat turpis felis vitae nunc. Donec vehicula velit vel eleifend semper. Etiam gravida, est eu commodo faucibus, urna turpis hendrerit neque, malesuada viverra neque turpis at magna. In fermentum placerat nibh non malesuada. Pellentesque eget mauris fringilla, elementum erat sed, porttitor justo. Praesent mollis elit nec felis placerat mollis. Nulla ipsum mi, ullamcorper et tellus nec, porttitor tincidunt leo. Fusce varius auctor ornare. Aenean ullamcorper eu massa et pellentesque. Aliquam erat volutpat. Pellentesque sed ante sit amet orci suscipit aliquam at eget ante. Aliquam erat volutpat. Vestibulum fermentum tellus id iaculis condimentum. Vivamus et nunc et felis scelerisque auctor. Nam ornare quis dui in pellentesque. Proin diam justo, imperdiet ut magna sed, lacinia efficitur massa. Sed nec tellus quis eros mollis pellentesque. Phasellus sit amet nisi lectus. Sed non commodo risus. Sed fermentum nulla quis tristique varius. Duis molestie urna sed magna ultrices condimentum. Proin massa velit, dignissim sit amet odio eu, tempor aliquam est. Etiam ac maximus enim, sed ultrices magna. Sed ut erat aliquam, varius metus nec, efficitur odio. Aenean sagittis euismod est ac rhoncus. Etiam maximus lectus sed erat feugiat, id semper turpis fringilla. Mauris maximus arcu metus, ac mattis neque venenatis eget. Suspendisse potenti. Interdum et malesuada fames ac ante ipsum primis in faucibus. Suspendisse lacus nisi, rutrum in nisl et, placerat semper dui. Curabitur commodo, lectus id aliquet iaculis, metus orci hendrerit dolor, quis porta ligula ligula eu odio. Sed dapibus lobortis blandit. Nunc volutpat mauris non vestibulum mollis. Praesent ornare mollis lectus, vitae finibus ante scelerisque ullamcorper. Cras ac dui scelerisque, efficitur quam elementum, cursus felis.",
    "Discover the reasons behind our architectural shift and the benefits we've seen since returning to a monolith.",
    "A technical deep dive into ActiveRecord optimizations and SQL tuning techniques.",
    "We're adopting new frontend technologies to improve user experience and developer velocity.",
    "Strategies and patterns we use to ensure our systems stay up even when parts fail.",
    "How we containerized our applications and orchestrated them with Kubernetes.",
    "An overview of the internal tools we've built to streamline our development workflow.",
    "Understanding how Ruby handles memory and how to debug memory leaks in production.",
    "Best practices for protecting your application data and user privacy.",
    "A case study on using Hotwire to build responsive SPAs without writing complex JavaScript."
  ][i]

  credit = [
    "Gumbel AlphaZero",
    "Computer Science",
    "Dummy Credit"
  ]

  post = Post.create!(
    title: title,
    summary: summary,
    author: "Kamil Lee",
    tags: tags,
    content: "<p>This is the main content for <strong>#{title}</strong>.</p><p>#{summary}</p><p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.</p>",
    published_at: Time.current - i.days
  )

  # Attach cover image
  image_files = [ "gumbel_alphazero_thumbnail.png", "cpu_scheduler_thumbnail.png", "dummy_thumbnail.png" ]
  image_file = image_files[i % image_files.length]
  image_path = Rails.root.join("app/assets/images/thumbnail", image_file)
  caption = credit[i % credit.length]

  # TODO: Caption 이 이미지에 적용되지 않는 이슈 확인
  if File.exist?(image_path)
    post.cover_image.attach(
      io: File.open(image_path),
      filename: image_file,
      content_type: "image/png",
      metadata: { credit: caption }
    )
    puts "  Attached #{image_file} to '#{title}'"
  else
    puts "  Could not find image: #{image_path}"
  end
end

puts "Created #{Post.count} posts."
