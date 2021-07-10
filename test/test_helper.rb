# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "bulkseed_mysql"

require "test-unit"

class MockDB
  attr_reader :host,
    :user,
    :password,
    :database,
    :queries

  def initialize
    @host = "mock_host"
    @user = "mock_user"
    @password = "mock_password"
    @database = "mock_db"
    @queries = []
  end

  def execute q
    @queries << q
  end
end
