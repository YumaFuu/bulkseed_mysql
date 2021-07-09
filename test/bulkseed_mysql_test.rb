# frozen_string_literal: true

require "test_helper"

class BulkseedMysqlTest < Test::Unit::TestCase
  test "VERSION" do
    assert do
      ::BulkseedMysql.const_defined?(:VERSION)
    end
  end

  test "something useful" do
    assert_equal("expected", "actual")
  end

  def test_ok
    BulkseedMysql.call(
      {
        id: 1,
      }
    )
  end
end
