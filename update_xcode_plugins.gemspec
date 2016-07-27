require File.expand_path('../lib/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'update_xcode_plugins'
  s.version     = UpdateXcodePlugins::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Mahdi Bchetnia']
  s.email       = ['injekter@gmail.com'] # Real email is on my website ;)
  s.homepage    = 'http://github.com/inket/update_xcode_plugins'
  s.summary     = 'Updates Xcode plug-ins to match the installed Xcode versions.'
  s.description = 'This tool adds the missing UUIDs into the installed Xcode plug-ins so that they can be loaded by newer versions of Xcode.'

  s.required_rubygems_version = '>= 1.3.6'
  s.rubyforge_project         = 'update_xcode_plugins'
  s.files                     = Dir['{lib}/**/*.rb', 'lib/bin/*', 'bin/*', 'LICENSE', '*.md']
  s.require_path              = 'lib'
  s.executables               = ['update_xcode_plugins']
  s.license                   = 'MIT'

  s.add_runtime_dependency 'colorize', '~> 0.8.1'
  s.add_runtime_dependency 'inquirer', '~> 0.2.1'
end
