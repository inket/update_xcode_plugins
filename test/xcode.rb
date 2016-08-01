require "minitest/autorun"
require_relative "../lib/update_xcode_plugins"

class TestXcode < Minitest::Test
  def self.runnable_methods
    [
      :test_that_xcode_has_correct_path,
      :test_that_xcode_bundle_is_valid,
      :test_that_xcode_has_correct_version,
      :test_that_xcode_returns_correct_uuid,
      :test_that_xcode_is_signed_by_default,
      :test_that_xcodebuild_is_signed_by_default,
      :test_that_test_plugin_builds_correctly,
      :test_that_test_plugin_doesnt_include_uuid_by_default,
      :test_that_uuid_is_added_correctly_to_test_plugin,
      :test_that_plugin_injects_into_xcodebuild_with_xcode7,
      :test_that_plugin_doesnt_inject_into_xcodebuild_with_xcode8,
      :test_that_xcode_is_unsigned_correctly,
      :test_that_xcodebuild_is_unsigned_correctly,
      :test_that_plugin_injects_into_xcodebuild_with_xcode8_after_unsign,
      :test_that_launch_agent_is_installed_correctly,
      :test_that_launch_agent_updates_plugins_when_plugins_are_changed,
      :test_that_launch_agent_is_uninstalled_correctly
    ]
  end

  def skip_if_xcode_7
    skip "Unnecessary test for old Xcode version." if @xcode.version.to_f < 8
  end

  def plugin_path
    "#{Dir.home}/Library/Application Support/Developer/Shared/Xcode/Plug-ins/"\
    "HelloWorld.xcplugin"
  end

  def plugin_injection_success_path
    "#{Dir.home}/Desktop/success"
  end

  def setup
    unless ENV["CI"] == "true" && ENV["TRAVIS"] == "true"
      warn "Tests should only be run on CI as they'll overwrite Xcode."
      exit
    end

    @xcode = Xcode.from_bundle("/Applications/Xcode.app")
    @plugin = XcodePlugin.from_bundle(plugin_path)
    @launch_agent =
      LaunchAgent.new(File.expand_path("bin/update_xcode_plugins"))
  end

  def teardown
    FileUtils.remove(plugin_injection_success_path, force: true)
  end

  def test_that_xcode_has_correct_path
    assert_equal "/Applications/Xcode.app", @xcode.path
  end

  def test_that_xcode_bundle_is_valid
    assert @xcode.valid?
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

  def test_that_xcode_returns_correct_uuid
    plist_path = "#{@xcode.path}/Contents/Info"
    uuid = `defaults read "#{plist_path}" DVTPlugInCompatibilityUUID`.strip

    assert_equal uuid, @xcode.uuid
    refute_nil @xcode.uuid
    refute_empty @xcode.uuid
    assert @xcode.uuid.match(/\A\h{8}-(?:\h{4}-){3}\h{12}\z/)
  end

  def test_that_xcode_is_signed_by_default
    skip_if_xcode_7

    assert @xcode.signed?
  end

  def test_that_xcodebuild_is_signed_by_default
    skip_if_xcode_7

    is_signed = `codesign -dv "#{@xcode.send(:xcodebuild_path)}" 2>/dev/null` &&
                  $CHILD_STATUS.exitstatus == 0
    assert is_signed
  end

  def test_that_test_plugin_builds_correctly
    Dir.chdir("test/HelloWorld") do
      `xcodebuild`
      assert_equal 0, $CHILD_STATUS.exitstatus
    end

    assert File.exist?(plugin_path)
  end

  def test_that_test_plugin_doesnt_include_uuid_by_default
    refute_nil @plugin

    plist_path = "#{@plugin.path}/Contents/Info"
    uuids = `defaults read "#{plist_path}" DVTPlugInCompatibilityUUIDs`.strip

    assert_equal "(\n)", uuids
    refute @plugin.has_uuid?(@xcode.uuid)
  end

  def test_that_uuid_is_added_correctly_to_test_plugin
    refute_nil @plugin

    @plugin.add_uuid(@xcode.uuid)

    plist_path = "#{@plugin.path}/Contents/Info"
    uuids = `defaults read "#{plist_path}" DVTPlugInCompatibilityUUIDs`.strip

    assert uuids.include?(@xcode.uuid)
    assert @plugin.has_uuid?(@xcode.uuid)
  end

  def test_that_plugin_injects_into_xcodebuild_with_xcode7
    skip unless @xcode.version.to_f < 8

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

    @xcode.unsign_binary!
    refute @xcode.signed?
  end

  def test_that_xcodebuild_is_unsigned_correctly
    skip_if_xcode_7

    @xcode.unsign_xcodebuild!
    is_signed = `codesign -dv "#{@xcode.send(:xcodebuild_path)}" 2>/dev/null` &&
                  $CHILD_STATUS.exitstatus == 0
    refute is_signed
  end

  def test_that_plugin_injects_into_xcodebuild_with_xcode8_after_unsign
    skip_if_xcode_7

    refute File.exist?(plugin_injection_success_path)
    `xcodebuild`
    assert File.exist?(plugin_injection_success_path)
  end

  def test_that_launch_agent_is_installed_correctly
    refute File.exist?(@launch_agent.launch_agent_path)
    launchctl_out = `launchctl list | grep #{@launch_agent.identifier} | wc -l`
    refute launchctl_out.strip == "1"

    @launch_agent.install

    assert File.exist?(@launch_agent.launch_agent_path)
    launchctl_out = `launchctl list | grep #{@launch_agent.identifier} | wc -l`
    assert launchctl_out.strip == "1"
  end

  def test_that_launch_agent_updates_plugins_when_plugins_are_changed
    FileUtils.remove_dir(@plugin.path, true)
    refute Dir.exist?(@plugin.path)

    Dir.chdir("test/HelloWorld") { `xcodebuild` }
    assert Dir.exist?(@plugin.path)

    puts `cat /tmp/#{@launch_agent.identifier}.err`
    puts `cat /tmp/#{@launch_agent.identifier}.out`
    sleep 2

    assert @plugin.has_uuid?(@xcode.uuid)
  end

  def test_that_launch_agent_is_uninstalled_correctly
    assert File.exist?(@launch_agent.launch_agent_path)
    launchctl_out = `launchctl list | grep #{@launch_agent.identifier} | wc -l`
    assert launchctl_out.strip == "1"

    @launch_agent.uninstall

    refute File.exist?(@launch_agent.launch_agent_path)
    launchctl_out = `launchctl list | grep #{@launch_agent.identifier} | wc -l`
    refute launchctl_out.strip == "1"
  end
end
