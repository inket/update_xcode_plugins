require "minitest/autorun"
require_relative "../lib/update_xcode_plugins"

class TestXcode < Minitest::Test
  def setup
    @xcode = Xcode.new("/Applications/Xcode.app")
  end

  def test_that_xcode_has_correct_path
    assert_equal "/Applications/Xcode.app", @xcode.path
  end

  def test_that_xcode_is_signed_by_default
    assert_equal true, @xcode.signed?
  end
end
