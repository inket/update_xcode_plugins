require_relative 'xcode'

class XcodeUnsigner
  extend CLI

  def self.unsign_xcode
    process 'Looking for Xcode...'
    xcodes = Xcode.find_xcodes
                  .select { |xcode| xcode.version.to_f >= 8 }
                  .select(&:signed?)

    separator

    if xcodes.empty?
      error "Didn't find any signed Xcode 8+ on your system."
      return
    end

    notice
    separator

    selection = Ask.list "Choose which Xcode you would like to unsign (use arrows)", xcodes
    return unless selection

    xcode = xcodes[selection]

    unsign_xcodebuild = Ask.confirm "Unsign xcodebuild too?"

    separator

    process 'Unsigning...'
    if xcode.unsign_binary! &&
       (!unsign_xcodebuild || (unsign_xcodebuild && xcode.unsign_xcodebuild!))
      success 'Finished! 🎉'
    else
      error "Could not unsign #{xcode.path}\n"\
            'Create an issue on https://github.com/inket/update_xcode_plugins/issues'
    end
  end

  def self.restore_xcode
    process 'Looking for Xcode...'
    xcodes = Xcode.find_xcodes
                  .select { |xcode| xcode.version.to_f >= 8 }
                  .select(&:restorable?)

    separator

    if xcodes.empty?
      error "Didn't find any Xcode 8+ that can be restored on your system."
      return
    end

    selection = Ask.list "Choose which Xcode you would like to restore (use arrows)", xcodes
    return unless selection

    xcode = xcodes[selection]

    separator

    process 'Restoring...'

    success = true

    if xcode.binary_restorable? && !xcode.restore_binary!
      error "Could not restore binary for #{xcode.path}"
      success = false
    end

    if xcode.xcodebuild_restorable? && !xcode.restore_xcodebuild!
      error "Could not restore xcodebuild for #{xcode.path}"
      success = false
    end

    success 'Finished! 🎉' if success
  end

  def self.notice
    puts [
      'Unsigning Xcode will make it skip library validation allowing it to load plugins.'.colorize(:yellow),
      'However, an unsigned Xcode presents security risks, '\
      'and will be untrusted by both Apple and your system.'.colorize(:red),
      "This tool will create a backup and allow you to restore Xcode's signature by running\n",
      '$ update_xcode_plugins --restore'.colorize(:light_blue)
    ]
  end
end
