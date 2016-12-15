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
      puts xcodes.map { |xcode| "- #{xcode.detailed_description}" }
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

    return if CLI.no_colors?

    if xcodes.any? { |xcode| xcode.version.to_f >= 8 }
      separator
      warning 'It seems that you have Xcode 8+ installed!'
      puts 'Some plugins might not work on recent versions of Xcode because of library validation.',
           "See #{'https://github.com/alcatraz/Alcatraz/issues/475'.underline}"

      separator
      puts "Run `#{'update_xcode_plugins --unsign'.bold}` to fix this."
    end
  end
end
