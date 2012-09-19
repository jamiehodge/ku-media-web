require './controllers/collections'
require './controllers/items'
require './controllers/assets'
require './controllers/sessions'

require 'securerandom'

require 'warden'
require './config/warden'

require 'rack/cache'

use Rack::Session::Cookie, secret: ENV['RACK_SESSION_SECRET'] || SecureRandom.hex(64)

use Warden::Manager do |m|
  m.default_strategies :password
  m.scope_defaults :default,
    action: 'sessions/unauthenticated'
  m.failure_app = self
end

use Rack::Cache,
  metastore:   ENV['RACK_CACHE_META_STORE'],
  entitystore: ENV['RACK_CACHE_ENTITY_STORE']

map '/' do
  run Collections
end

map '/items' do
  run Items
end

map '/assets' do
  run Assets
end

map '/sessions' do
  run Sessions
end
