require_relative 'bundle'

class XcodePlugin < Bundle
  def self.find_plugins
    plugins_path = "#{Dir.home}/Library/Application Support/Developer/Shared/Xcode/Plug-ins/"

    unless Dir.exist?(plugins_path)
      puts "Couldn't find Plug-ins directory."
      return []
    end

    Dir.entries(plugins_path).collect do |plugin_path|
      XcodePlugin.from_bundle("#{plugins_path}#{plugin_path}")
    end.compact.keep_if(&:valid?)
  end

  def self.from_bundle(path)
    plugin = new(path)
    plugin.valid? ? plugin : nil
  end

  def valid?
    not_hidden = !path.split('/').last.start_with?('.')
    is_plugin = path.end_with?('.xcplugin')
    has_info = File.exist?(info_path)

    not_hidden && is_plugin && has_info
  end

  def has_uuid?(uuid)
    defaults_read('DVTPlugInCompatibilityUUIDs').include?(uuid)
  end

  def add_uuid(uuid)
    return false if has_uuid?(uuid)

    defaults_write('DVTPlugInCompatibilityUUIDs', '-array-add', uuid)
    true
  end

  def to_s
    "#{path.split('/').last.sub(/\.xcplugin$/, '')} (#{version})"
  end
end
