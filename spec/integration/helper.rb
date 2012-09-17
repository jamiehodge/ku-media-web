ENV['RACK_ENV'] = 'test'

require 'bundler/setup'
require 'minitest/autorun'
require 'capybara/dsl'
require 'capybara/poltergeist'
require 'rack'

class MiniTest::Spec
  include Capybara::DSL
  Capybara.default_driver = :poltergeist
  Capybara.app = eval "Rack::Builder.new {( " + File.read(File.dirname(__FILE__) + '/../../config.ru') + "\n )}"
end

