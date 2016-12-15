require "simplecov"
require "coveralls"

SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start do
  # Ignore interactive scripts (and helper) that can't be tested
  add_filter "lib/plugins_updater.rb"
  add_filter "lib/xcode_unsigner.rb"
  add_filter "lib/cli.rb"
end

require "minitest/autorun"
require_relative "../lib/update_xcode_plugins"

unless ENV["CI"] == "true" && ENV["TRAVIS"] == "true"
  warn "Tests should only be run on CI as they'll overwrite Xcode."
  exit
end

class TestXcode < Minitest::Test
  extend Minitest::Spec::DSL

  let(:xcode) { Xcode.new("/Applications/Xcode.app") }
  let(:plugin) do
    XcodePlugin.new(
      "#{Dir.home}/Library/Application Support/Developer/Shared/Xcode"\
      "/Plug-ins/HelloWorld.xcplugin"
    )
  end
  let(:launch_agent) do
    LaunchAgent.new(
      Gem.bin_path("update_xcode_plugins", "update_xcode_plugins")
    )
  end

  # Test execution order needs to be set manually, which is why all tests are limited to one file
  def self.runnable_methods
    [
      :test_that_bundle_cannot_be_used_directly,
      :test_that_xcode_has_correct_path,
      :test_that_xcode_bundle_is_valid,
      :test_that_xcode_has_correct_version,
      :test_that_xcode_returns_correct_uuid,
      :test_that_xcode_is_signed_by_default,
      :test_that_xcodebuild_is_signed_by_default,
      :test_that_test_plugin_is_invalid_when_nonexistent,
      :test_that_find_plugins_returns_empty_array_when_no_plugins_are_installed,
      :test_that_test_plugin_builds_correctly,
      :test_that_find_plugins_returns_installed_plugins,
      :test_that_test_plugin_doesnt_include_uuid_by_default,
      :test_that_uuid_isnt_added_to_test_plugin_in_dry_run,
      :test_that_uuid_is_added_correctly_to_test_plugin,
      :test_that_plugin_injects_into_xcodebuild_with_xcode7,
      :test_that_plugin_doesnt_inject_into_xcodebuild_with_xcode8,
      :test_that_xcode_is_unsigned_correctly,
      :test_that_xcodebuild_is_unsigned_correctly,
      :test_that_plugin_injects_into_xcodebuild_with_xcode8_after_unsign,
      :test_that_launch_agent_is_installed_correctly_via_cli,
      :test_that_launch_agent_is_updated_correctly_via_cli,
      :test_that_launch_agent_is_uninstalled_correctly_via_cli,
      :test_that_launch_agent_is_installed_correctly,
      :test_that_launch_agent_updates_plugins_when_plugins_are_changed,
      :test_that_launch_agent_is_uninstalled_correctly,
      :test_that_xcode_cannot_be_found_using_mdfind_with_spotlight_disabled,
      :test_that_xcode_can_be_found_using_fallback_with_spotlight_disabled,
      :test_that_xcode_is_restored_correctly,
      :test_that_xcodebuild_is_restored_correctly
    ]
  end

  def skip_if_xcode_7
    skip "Unnecessary test for old Xcode version." if xcode.version.to_f < 8
  end

  def plugin_injection_success_path
    "#{Dir.home}/Desktop/success"
  end

  def teardown
    FileUtils.remove(plugin_injection_success_path, force: true)
  end

  def test_that_bundle_cannot_be_used_directly
    refute Bundle.new("/Applications/Xcode.app").valid?
  end

  def test_that_xcode_has_correct_path
    assert_equal "/Applications/Xcode.app", xcode.path
  end

  def test_that_xcode_bundle_is_valid
    assert xcode.valid?
  end

  def test_that_xcode_has_correct_version
    if ENV["TRAVIS_XCODE_VERSION"] == "73"
      assert_equal "7.3.1", xcode.version
    elsif ENV["TRAVIS_XCODE_VERSION"] == "8"
      assert_equal "8.0", xcode.version
    elsif ENV["TRAVIS_XCODE_VERSION"] == "81"
      assert_equal "8.1", xcode.version
    elsif ENV["TRAVIS_XCODE_VERSION"] == "82"
      assert_equal "8.2", xcode.version
    else
      fail "Unexpected Xcode version #{xcode.version}"
    end
  end

  def test_that_xcode_returns_correct_uuid
    plist_path = "#{xcode.path}/Contents/Info"
    uuid = `defaults read "#{plist_path}" DVTPlugInCompatibilityUUID`.strip

    assert_equal uuid, xcode.uuid
    refute_nil xcode.uuid
    refute_empty xcode.uuid
    assert xcode.uuid.match(/\A\h{8}-(?:\h{4}-){3}\h{12}\z/)
  end

  def test_that_xcode_is_signed_by_default
    skip_if_xcode_7

    assert xcode.signed?
    assert_equal "Xcode (#{xcode.version}) [Signed]: #{xcode.path}", xcode.to_s
  end

  def test_that_xcodebuild_is_signed_by_default
    skip_if_xcode_7

    is_signed = `codesign -dv "#{xcode.send(:xcodebuild_path)}" 2>/dev/null` &&
                  $CHILD_STATUS.exitstatus == 0
    assert is_signed
  end

  def test_that_test_plugin_is_invalid_when_nonexistent
    refute plugin.valid?
    assert_nil XcodePlugin.from_bundle(plugin.path)
  end

  def test_that_find_plugins_returns_empty_array_when_no_plugins_are_installed
    assert_equal [], XcodePlugin.find_plugins
  end

  def test_that_test_plugin_builds_correctly
    Dir.chdir("test/HelloWorld") do
      `xcodebuild`
      assert_equal 0, $CHILD_STATUS.exitstatus
    end

    assert File.exist?(plugin.path)
    assert plugin.valid?
    refute_nil XcodePlugin.from_bundle(plugin.path)

    assert_equal "HelloWorld (1.0)", plugin.to_s
  end

  def test_that_find_plugins_returns_installed_plugins
    found_plugins = XcodePlugin.find_plugins
    assert_equal 1, found_plugins.count
    assert_equal plugin.bundle_identifier, found_plugins.first.bundle_identifier
  end

  def test_that_test_plugin_doesnt_include_uuid_by_default
    refute_nil plugin

    plist_path = "#{plugin.path}/Contents/Info"
    uuids = `defaults read "#{plist_path}" DVTPlugInCompatibilityUUIDs`.strip

    assert_equal "(\n)", uuids
    refute plugin.has_uuid?(xcode.uuid)
  end

  def test_that_uuid_isnt_added_to_test_plugin_in_dry_run
    refute_nil plugin

    CLI.stub :dry_run?, true do
      plugin.add_uuid(xcode.uuid)
    end

    refute plugin.has_uuid?(xcode.uuid)
  end

  def test_that_uuid_is_added_correctly_to_test_plugin
    refute_nil plugin

    plugin.add_uuid(xcode.uuid)

    plist_path = "#{plugin.path}/Contents/Info"
    uuids = `defaults read "#{plist_path}" DVTPlugInCompatibilityUUIDs`.strip

    assert uuids.include?(xcode.uuid)
    assert plugin.has_uuid?(xcode.uuid)
  end

  def test_that_plugin_injects_into_xcodebuild_with_xcode7
    skip unless xcode.version.to_f < 8

    refute File.exist?(plugin_injection_success_path)
    `xcodebuild`
    assert File.exist?(plugin_injection_success_path)
  end

  def test_that_plugin_doesnt_inject_into_xcodebuild_with_xcode8
    skip_if_xcode_7

    refute File.exist?(plugin_injection_success_path)
    `xcodebuild`
    refute File.exist?(plugin_injection_success_path)
  end

  def test_that_xcode_is_unsigned_correctly
    skip_if_xcode_7

    xcode.unsign_binary!
    refute xcode.signed?

    new_xcode = Xcode.new("/Applications/Xcode.app")
    refute new_xcode.signed?
    assert_equal "Xcode (#{xcode.version}) [Unsigned]: #{xcode.path}", new_xcode.to_s
  end

  def test_that_xcodebuild_is_unsigned_correctly
    skip_if_xcode_7

    xcode.unsign_xcodebuild!
    is_signed = `codesign -dv "#{xcode.send(:xcodebuild_path)}" 2>/dev/null` &&
                  $CHILD_STATUS.exitstatus == 0
    refute is_signed
  end

  def test_that_plugin_injects_into_xcodebuild_with_xcode8_after_unsign
    skip_if_xcode_7

    refute File.exist?(plugin_injection_success_path)
    `xcodebuild`
    assert File.exist?(plugin_injection_success_path)
  end

  def test_that_launch_agent_is_installed_correctly_via_cli
    refute LaunchAgent.installed?

    LaunchAgent.install("/some/random/path/update_xcode_plugins-0.0/bin/update_xcode_plugins")
    assert LaunchAgent.installed?

    # LaunchAgent should be stale because the version doesn't match
    assert LaunchAgent.stale?

    # Expect LaunchAgent.warning to be called because it's warning us about
    # the plugin being already installed
    mock = MiniTest::Mock.new
    mock.expect(:call, nil, ["Launch agent is already installed!"])
    LaunchAgent.stub(:warning, mock) do
      LaunchAgent.install("")
    end
    mock.verify
  end

  def test_that_launch_agent_is_updated_correctly_via_cli
    assert LaunchAgent.installed?

    LaunchAgent.update_if_stale(launch_agent.bin_path)
    assert LaunchAgent.installed?

    refute LaunchAgent.stale?
  end

  def test_that_launch_agent_is_uninstalled_correctly_via_cli
    assert LaunchAgent.installed?

    LaunchAgent.uninstall
    refute LaunchAgent.installed?
    refute LaunchAgent.stale?

    # Expect LaunchAgent.warning to be called because it's warning us about
    # the plugin being already uninstalled
    mock = MiniTest::Mock.new
    mock.expect(:call, nil, ["Launch agent is not installed!"])
    LaunchAgent.stub(:warning, mock) do
      LaunchAgent.uninstall
    end
    mock.verify
  end

  def test_that_launch_agent_is_installed_correctly
    refute LaunchAgent.installed?
    refute File.exist?(launch_agent.launch_agent_path)
    launchctl_out = `launchctl list | grep #{launch_agent.identifier} | wc -l`
    refute launchctl_out.strip == "1"

    launch_agent.install

    assert File.exist?(launch_agent.launch_agent_path)
    launchctl_out = `launchctl list | grep #{launch_agent.identifier} | wc -l`
    assert_equal "1", launchctl_out.strip
    assert LaunchAgent.installed?

    refute LaunchAgent.stale?
  end

  def test_that_launch_agent_updates_plugins_when_plugins_are_changed
    FileUtils.remove_dir(plugin.path, true)
    refute Dir.exist?(plugin.path)

    Dir.chdir("test/HelloWorld") { `xcodebuild` }
    assert Dir.exist?(plugin.path)

    refute plugin.has_uuid?(xcode.uuid)
    sleep 10
    assert plugin.has_uuid?(xcode.uuid)
  end

  def test_that_launch_agent_is_uninstalled_correctly
    assert File.exist?(launch_agent.launch_agent_path)
    launchctl_out = `launchctl list | grep #{launch_agent.identifier} | wc -l`
    assert_equal "1", launchctl_out.strip

    launch_agent.uninstall

    refute File.exist?(launch_agent.launch_agent_path)
    launchctl_out = `launchctl list | grep #{launch_agent.identifier} | wc -l`
    assert_equal "0", launchctl_out.strip
    refute LaunchAgent.installed?
  end

  def test_that_xcode_cannot_be_found_using_mdfind_with_spotlight_disabled
    `sudo mdutil -a -i off`
    mdfind = `mdfind kMDItemCFBundleIdentifier = "com.apple.dt.Xcode" | wc -l`
    assert_equal "0", mdfind.strip
  end

  def test_that_xcode_can_be_found_using_fallback_with_spotlight_disabled
    mdfind = `mdfind kMDItemCFBundleIdentifier = "com.apple.dt.Xcode" | wc -l`
    assert_equal "0", mdfind.strip

    refute Xcode.find_xcodes.empty?
  end

  def test_that_xcode_is_restored_correctly
    assert xcode.restorable?
    assert xcode.binary_restorable?

    refute xcode.signed?
    assert xcode.restore_binary!
    refute xcode.signed?

    assert xcode.restorable? # xcodebuild is still unsigned
    refute xcode.binary_restorable?
  end

  def test_that_xcodebuild_is_restored_correctly
    assert xcode.restorable?
    assert xcode.xcodebuild_restorable?

    assert xcode.restore_xcodebuild!

    refute xcode.restorable?
    refute xcode.xcodebuild_restorable?
  end
end
