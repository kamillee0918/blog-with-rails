# API Documentation with RSwag

## 📚 Overview

This project uses [RSwag](https://github.com/rswag/rswag) to generate interactive API documentation using the OpenAPI 3.0 specification.

## 🚀 Setup

### 1. Install Dependencies

```bash
bundle install
```

### 2. Generate Swagger Documentation

Run the following command to generate the OpenAPI YAML file from your specs:

```bash
RAILS_ENV=test bundle exec rake rswag:specs:swaggerize
```

Or use the shorter alias:

```bash
RAILS_ENV=test bundle exec rake rswag
```

### 3. Start the Server

```bash
rails server
```

### 4. View Documentation

Open your browser and visit:

```
http://localhost:3000/api-docs
```

## 📝 Writing API Specs

API specs are located in `spec/requests/api/` directory. Each spec file describes one or more API endpoints.

### Example Spec Structure

```ruby
# spec/requests/api/search_spec.rb
require "swagger_helper"

RSpec.describe "Search API", type: :request do
  path "/search" do
    get "Search blog posts" do
      tags "Search"
      produces "application/json"
      
      parameter name: :q, in: :query, type: :string, required: false
      
      response "200", "successful" do
        schema type: :object,
               properties: {
                 query: { type: :string },
                 posts: { type: :array }
               }
        
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["posts"]).to be_an(Array)
        end
      end
    end
  end
end
```

### Key Components

- **`swagger_helper`**: Contains global OpenAPI configuration
- **`path`**: Defines the API endpoint path
- **`parameter`**: Describes request parameters
- **`response`**: Describes possible responses
- **`schema`**: Defines the response structure
- **`run_test!`**: Executes the actual request and tests

## 📋 Current API Endpoints

### Search API
- **GET** `/search` - Search blog posts with optional category filter

### Members API
- **GET** `/members/api/session` - Get current session information
- **DELETE** `/members/api/session` - Logout and destroy session
- **GET** `/members/api/member` - Get current user information
- **PUT** `/members/api/member` - Update user information
- **POST** `/members/api/send-magic-link` - Send magic link for authentication
- **GET** `/members/api/integrity-token` - Get integrity token for secure operations

## 🔧 Configuration

### swagger_helper.rb

Global configuration for OpenAPI documentation:

```ruby
config.openapi_specs = {
  "v1/swagger.yaml" => {
    openapi: "3.0.1",
    info: {
      title: "Kamil Lee's Blog API",
      version: "v1"
    },
    servers: [
      { url: "http://localhost:3000" }
    ]
  }
}
```

### Routes

RSwag routes are mounted in `config/routes.rb`:

```ruby
mount Rswag::Ui::Engine => "/api-docs"
mount Rswag::Api::Engine => "/api-docs"
```

## 🎯 Best Practices

1. **Keep specs with implementation**: Write API specs alongside your API development
2. **Use meaningful tags**: Group related endpoints with tags
3. **Document all parameters**: Include descriptions and examples
4. **Test responses**: Always include `run_test!` to validate schemas
5. **Version your API**: Use URL versioning (e.g., `/api/v1/...`)

## 🧪 Testing

API specs are also functional tests. Run them with:

```bash
# Run all API specs
bundle exec rspec spec/requests/api

# Run specific spec
bundle exec rspec spec/requests/api/search_spec.rb
```

## 📖 Additional Resources

- [RSwag GitHub](https://github.com/rswag/rswag)
- [OpenAPI Specification](https://swagger.io/specification/)
- [Swagger UI Documentation](https://swagger.io/tools/swagger-ui/)

## 🎨 Customization

### Adding Authentication

To document authenticated endpoints, update `swagger_helper.rb`:

```ruby
components: {
  securitySchemes: {
    session_token: {
      type: :apiKey,
      name: "session_token",
      in: :cookie
    }
  }
}
```

Then in your spec:

```ruby
security [{ session_token: [] }]
```

### Custom Response Examples

```ruby
response "200", "successful" do
  examples "application/json" => {
    query: "Rails",
    total: 5,
    posts: [
      { id: 1, title: "Getting Started with Rails" }
    ]
  }
  
  run_test!
end
```

## 🚧 TODO

- [ ] Document all Members API endpoints
- [ ] Add authentication examples to docs
- [ ] Create API versioning strategy
- [ ] Add request/response examples for all endpoints
- [ ] Set up automated API testing in CI/CD

---

**Last Updated**: 2025-11-02
**Maintainer**: Kamil Lee
