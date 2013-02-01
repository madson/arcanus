require "mongoid"

Mongoid.load!("config/mongoid.yml", ENV["RACK_ENV"])
Mongoid.raise_not_found_error = false

require "openssl"
require "json"
require "settingslogic"
require "sinatra/base"

require "lib/models/setting"
require "lib/models/author"
require "lib/models/entry"

require "lib/services/author_service"
require "lib/services/entry_service"

require "lib/digest"
require "lib/helpers"
require "lib/api"