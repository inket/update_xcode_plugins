module CLI
  def self.dry_run?
    ARGV.include?('-d') || ARGV.include?('--dry-run')
  end

  def self.install_launch_agent?
    ARGV.include?('--install-launch-agent')
  end

  def self.uninstall_launch_agent?
    ARGV.include?('--uninstall-launch-agent')
  end

  def self.unsign_xcode?
    ARGV.include?('--unsign')
  end

  def self.restore_xcode?
    ARGV.include?('--restore')
  end

  def self.no_colors?
    ARGV.include?('--no-colors')
  end

  def self.non_interactive?
    ARGV.include?('--non-interactive')
  end

  def self.codesign_exists?
    `which codesign` && $CHILD_STATUS.exitstatus == 0
  end

  def self.chown_if_required(path)
    return yield if File.owned?(path)

    puts
    puts "* Changing ownership of #{path} (will be restored after)".colorize(:light_blue)

    previous_owner = File.stat(path).uid
    system("sudo chown $(whoami) \"#{path}\"")

    raise "Could not change ownership of #{path}" unless File.owned?(path)

    result = yield
    system("sudo chown #{previous_owner} \"#{path}\"")
    puts "* Restored ownership of #{path}".colorize(:light_blue)

    result
  end

  {
    title: :blue,
    process: :light_blue,
    warning: :yellow,
    error: :red,
    success: :green
  }.each do |type, color|
    if CLI.no_colors?
      define_method type.to_sym do |str| puts str end
    else
      define_method type.to_sym do |str| puts str.colorize(color) end
    end
  end

  def separator
    puts
  end
end
