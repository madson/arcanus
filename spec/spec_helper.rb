ENV["RACK_ENV"] = "test"

require "rubygems"
require "bundler"
Bundler.setup

if ENV["COVERAGE"]
  require "simplecov"

  SimpleCov.start do
    add_filter "/spec/"
  end
end

$LOAD_PATH.unshift File.expand_path("../..", __FILE__)

require "rspec"
require "rack/test"
require "factory_girl"
require "json"

FactoryGirl.find_definitions

require "lib/arcanus"
require "spec/support/matchers/include_json"
require "spec/support/matchers/include_error"

RSpec.configure do |config|
  config.order = :random

  config.include FactoryGirl::Syntax::Methods
  config.include Rack::Test::Methods
  config.include Matchers

  config.expect_with(:rspec) { |c| c.syntax = :expect }

  config.before do
    Author.delete_all
    Entry.delete_all
  end
end