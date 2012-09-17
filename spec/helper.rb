ENV['RACK_ENV'] = 'test'

require 'bundler/setup'
require 'minitest/autorun'
require 'rack/test'
require 'nokogiri'

require 'sequel'

class MiniTest::Spec
  def run *args, &block
    Sequel::Model.db.transaction(rollback: :always) {super}
  end
end
