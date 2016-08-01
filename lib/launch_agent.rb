class LaunchAgent
  extend CLI

  attr_accessor :bin_path

  def self.install(bin_path)
    if !installed?
      LaunchAgent.new(File.expand_path(bin_path)).install
      success 'Installed! 🎉'
    else
      warning 'Launch agent is already installed!'
    end
  end

  def self.uninstall
    if installed?
      LaunchAgent.new.uninstall
      success 'Uninstalled! 🎉'
    else
      warning 'Launch agent is not installed!'
    end
  end

  def self.update_if_stale(bin_path)
    return unless stale?

    launch_agent = LaunchAgent.new(File.expand_path(bin_path))
    launch_agent.uninstall
    launch_agent.install
    success 'Updated launch agent.'
  end

  def self.stale?
    if installed?
      path = LaunchAgent.new.launch_agent_path

      agent_xml = ''
      File.open(path, 'r') do |file|
        agent_xml = file.read
      end

      match = agent_xml.match(/update_xcode_plugins-(.*?)\//)
      installed_version = match ? match[1] : nil

      if installed_version && UpdateXcodePlugins::VERSION != installed_version
        return true
      end
    end

    false
  end

  def self.installed?
    File.exist?(LaunchAgent.new.launch_agent_path)
  end

  def initialize(bin_path = nil)
    self.bin_path = bin_path
  end

  def install
    File.open(launch_agent_path, 'w') do |file|
      file.write(xml)
    end

    `launchctl load "#{launch_agent_path}"`
  end

  def uninstall
    `launchctl unload "#{launch_agent_path}"`

    File.delete(launch_agent_path) if File.exist?(launch_agent_path)
  end

  def identifier
    'jp.mahdi.update_xcode_plugins'
  end

  def launch_agent_path
    "#{Dir.home}/Library/LaunchAgents/#{identifier}.plist"
  end

  def watch_paths
    [
      '/Applications/Xcode.app',
      '/Applications/Xcode-beta.app',
      '~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/'
    ]
  end

  def watch_paths_xml
    watch_paths.map do |path|
      "<string>#{path}</string>"
    end.join("\n")
  end

  def xml
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
      <!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
      <plist version=\"1.0\">
      <dict>
        <key>Label</key>
        <string>#{identifier}</string>
        <key>ProgramArguments</key>
        <array>
          <string>/usr/bin/env</string>
          <string>ruby</string>
          <string>#{bin_path}</string>
          <string>--no-colors</string>
          <string>--non-interactive</string>
        </array>
        <key>RunAtLoad</key>
        <false/>
        <key>StandardErrorPath</key>
        <string>/tmp/#{identifier}.err</string>
        <key>StandardOutPath</key>
        <string>/tmp/#{identifier}.out</string>
        <key>WatchPaths</key>
        <array>
          #{watch_paths_xml}
        </array>
      </dict>
    </plist>"
  end
end
