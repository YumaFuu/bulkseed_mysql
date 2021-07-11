# frozen_string_literal: true

require "test_helper"

class BulkseedMysqlTest < Test::Unit::TestCase
  test "VERSION" do
    assert do
      ::BulkseedMysql.const_defined?(:VERSION)
    end
  end

  USER_SQL = "./test/expect-user.sql"
  ADMIN_SQL = "./test/expect-admin.sql"

  def setup
    @conn = MockDB.new

    BulkseedMysql.init(
      db_connection: @conn,
      db_execute_command: :execute,
    )
  end

  def test_with_prepare
    seed = BulkseedMysql.new
    seed.prepare "users" do |s|
      s.data = [
        {
          id: 1,
          name: "name1",
          age: 10,
        },
        {
          id: 2,
          name: "name2",
          age: 28,
        },
        {
          id: 3,
          name: "name3",
          age: 35,
        },
      ]
    end

    seed.prepare do |s|
      s.table = "admins"
      s.data = [
        {
          id: 1,
          name: "name1",
          email: "admin1@sample.com",
        },
        {
          id: 2,
          name: "name2",
          email: "admin2@sample.com",
        },
        {
          id: 3,
          name: "name3",
          email: "admin3@sample.com",
        },
      ]
    end

    seed.call

    expect = File.read(USER_SQL).gsub(/[\r\n]/, "")
    actual = @conn.queries[0].gsub(/[\r\n]/, "")

    assert_equal expect, actual

    expect = File.read(ADMIN_SQL).gsub(/[\r\n]/, "")
    actual = @conn.queries[1].gsub(/[\r\n]/, "")

    assert_equal expect, actual
  end

  def test_without_prepare
    BulkseedMysql.call "users" do |s|
      s.columns = ["id", "name", "age"]
      s.data = [
        [1, "name1", 10],
        [2, "name2", 28],
        [3, "name3", 35],
      ]
    end

    expect = File.read(USER_SQL).gsub(/[\r\n]/, "")
    actual = @conn.queries[0].gsub(/[\r\n]/, "")

    assert_equal expect, actual
  end
end
