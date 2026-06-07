# frozen_string_literal: true

require 'rspec/openapi'

RSpec::OpenAPI.title = 'Task Tracker API'
RSpec::OpenAPI.application_version = '1.0.0'
RSpec::OpenAPI.path = 'doc/openapi.yaml'
RSpec::OpenAPI.servers = [{ url: 'http://localhost:3000' }]
RSpec::OpenAPI.comment = <<~COMMENT
  Auto-generated from request specs by rspec-openapi.
  Do not edit by hand — regenerate with: OPENAPI=1 bundle exec rspec spec/requests
COMMENT
