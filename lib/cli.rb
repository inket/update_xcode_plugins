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

  {
    title: :blue,
    process: :magenta,
    warning: :yellow,
    error: :red,
    success: :green
  }.each do |type, color|
    define_method type.to_sym do |str| puts str.colorize(color) end
  end

  def separator
    puts
  end
end
