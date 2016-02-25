class CLI
  def self.dry_run?
    ARGV.include?('-d') || ARGV.include?('--dry-run')
  end

  def self.install_launch_agent?
    ARGV.include?('--install-launch-agent')
  end

  def self.uninstall_launch_agent?
    ARGV.include?('--uninstall-launch-agent')
  end
end
