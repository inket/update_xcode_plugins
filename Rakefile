require 'bundler'
Bundler.setup

gemspec = eval(File.read('update_xcode_plugins.gemspec'))

task build: "#{gemspec.full_name}.gem"

file "#{gemspec.full_name}.gem" => gemspec.files + ['update_xcode_plugins.gemspec'] do
  system 'gem build update_xcode_plugins.gemspec'
  system "gem install update_xcode_plugins-#{UpdateXcodePlugins::VERSION}.gem"
end
