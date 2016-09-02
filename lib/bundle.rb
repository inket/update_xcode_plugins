require_relative 'cli'

class Bundle
  attr_accessor :path

  def initialize(path)
    self.path = path.strip
  end

  def valid?
    false
  end

  def info_path
    "#{path}/Contents/Info.plist"
  end

  def bundle_identifier
    defaults_read("CFBundleIdentifier")
  end

  def version
    defaults_read('CFBundleShortVersionString')
  end

  def defaults_read(key)
    plist_path = "#{path}/Contents/Info"
    `defaults read "#{plist_path}" #{key}`.strip
  end

  def defaults_write(*args)
    plist_path = "#{path}/Contents/Info"
    command = "defaults write \"#{plist_path}\" #{args.join(' ')}"

    if CLI.dry_run?
      puts command
    else
      `#{command}`.strip
    end
  end
end
