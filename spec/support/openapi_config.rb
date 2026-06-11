# frozen_string_literal: true

require 'rspec/openapi'

RSpec::OpenAPI.title = 'Task Tracker API'
RSpec::OpenAPI.application_version = '1.0.0'
RSpec::OpenAPI.comment = <<~COMMENT
  Auto-generated from request specs by rspec-openapi.
  Do not edit by hand — regenerate with: OPENAPI=1 bundle exec rspec spec/requests
COMMENT

RSpec::OpenAPI.servers = [
  {
    url: 'http://127.0.0.1:3000',
    description: 'Local'
  }
]

RSpec::OpenAPI.path = -> (example) do
  case example.file_path
  when %r{spec/requests/tasks/one_offs/} then 'swagger/one_offs.openapi.yaml'
  when %r{spec/requests/tasks/recurring/} then 'swagger/recurring.openapi.yaml'
  when %r{spec/requests/tasks/} then 'swagger/tasks.openapi.yaml'
  when %r{spec/requests/tags/} then 'swagger/tags.openapi.yaml'
  when %r{spec/requests/users/} then 'swagger/users.openapi.yaml'
  else 'swagger/main.openapi.yaml'
  end
end
