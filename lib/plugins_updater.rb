require_relative 'xcode'
require_relative 'xcode_plugin'

class PluginsUpdater
  def self.update_plugins
    xcodes = Xcode.find_xcodes

    if xcodes.empty?
      puts "Didn't find any Xcode installed on your system."
      return
    else
      puts 'Found:'
      puts xcodes
    end

    puts separator

    plugins = XcodePlugin.find_plugins

    if plugins.empty?
      puts "Didn't find any Xcode Plug-in installed on your system."
      return
    else
      puts 'Plugins:'
      puts plugins
    end

    puts separator
    puts 'Updating...'

    uuids = xcodes.collect(&:uuid)
    uuids.each do |uuid|
      plugins.each do |plugin|
        if plugin.add_uuid(uuid) && !CLI.dry_run?
          puts "Added #{uuid} to #{plugin}"
        end
      end
    end

    puts separator
    puts 'Done.'
  end

  def self.separator
    '-----------------------------------------------'
  end
end
