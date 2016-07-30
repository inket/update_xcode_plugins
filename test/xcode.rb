require "minitest/autorun"
require_relative "../lib/update_xcode_plugins"

class TestXcode < Minitest::Test
  def setup
    unless ENV["CI"] == "true" && ENV["TRAVIS"] == "true"
      warn "Tests should only be run on CI as they'll overwrite Xcode."
      exit
    end

    @xcode = Xcode.new("/Applications/Xcode.app")
  end

  def test_that_xcode_has_correct_path
    assert_equal "/Applications/Xcode.app", @xcode.path
  end

  def test_that_xcode_bundle_is_valid
    assert_equal true, @xcode.valid?
  end

  def test_that_xcode_has_correct_version
    if ENV["TRAVIS_XCODE_VERSION"] == "73"
      assert_equal "7.3.1", @xcode.version
    elsif ENV["TRAVIS_XCODE_VERSION"] == "8"
      assert_equal "8.0", @xcode.version
    else
      fail "Unexpected Xcode version #{@xcode.version}"
    end
  end

  def test_that_xcode_is_signed_by_default
    assert_equal true, @xcode.signed?
  end

  def test_that_xcode_gets_unsigned_correctly
    return unless @xcode.version.to_f >= 8

    @xcode.unsign_binary!
    assert_equal false, @xcode.signed?
  end
end
