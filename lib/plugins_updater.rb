require_relative 'xcode'
require_relative 'xcode_plugin'

class PluginsUpdater
  extend CLI

  def self.update_plugins
    xcodes = Xcode.find_xcodes

    if xcodes.empty?
      error "Didn't find any Xcode installed on your system."
      return
    else
      title 'Found:'
      puts xcodes.map { |s| "- #{s}" }
    end

    separator

    plugins = XcodePlugin.find_plugins

    if plugins.empty?
      error "Didn't find any Xcode Plug-in installed on your system."
      return
    else
      title 'Plugins:'
      puts plugins.map { |s| "- #{s}" }
    end

    separator
    process 'Updating...'

    uuids = xcodes.collect(&:uuid)
    uuids.each do |uuid|
      plugins.each do |plugin|
        if plugin.add_uuid(uuid) && !CLI.dry_run?
          success "Added #{uuid} to #{plugin}"
        end
      end
    end

    separator
    success 'Finished! 🎉'
  end
end
