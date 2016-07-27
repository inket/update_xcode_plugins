require 'bundler'
Bundler.setup

gemspec_filename = 'update_xcode_plugins.gemspec'
gemspec = eval(File.read(gemspec_filename))
gem_filename = "#{gemspec.full_name}.gem"

system "rm #{gem_filename}"

task default: gem_filename

file gem_filename => gemspec.files + [gemspec_filename] do
  system "gem uninstall -ax #{gemspec.name} 2>/dev/null"
  system "gem build #{gemspec_filename}"
  system "gem install #{gemspec.full_name}.gem"
end
