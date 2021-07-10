# frozen_string_literal: true

require "test_helper"

class BulkseedMysqlTest < Test::Unit::TestCase
  test "VERSION" do
    assert do
      ::BulkseedMysql.const_defined?(:VERSION)
    end
  end

  def setup
    @expect_file = "./test/expect-user.sql"

    @mock_conn = MockDB.new

    BulkseedMysql.init(
      db_connection: @mock_conn,
      db_execute_command: :execute,
    )
    @seed = BulkseedMysql.new @mock_conn
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

    seed.call

    expect = File.read(@expect_file).chomp
    actual = @mock_conn.queries[0].chomp

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

    expect = File.read(@expect_file).chomp
    actual = @mock_conn.queries[0].chomp

    assert_equal expect, actual
  end
end
