require "rubygems"
require "bundler"
Bundler.setup

$LOAD_PATH.unshift File.expand_path("..", __FILE__)

require "lib/arcanus"
run Api