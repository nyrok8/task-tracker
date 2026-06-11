# frozen_string_literal: true

RSpec.configure do |config|
  config.before { Tag.reset_names }
end
