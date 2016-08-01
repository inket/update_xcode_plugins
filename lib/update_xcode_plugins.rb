require 'English'
require 'fileutils'
require_relative 'cli'
require 'colorize' unless CLI.no_colors?
require 'inquirer' unless CLI.non_interactive?
require_relative 'version'
require_relative 'plugins_updater'
require_relative 'xcode_unsigner'
require_relative 'launch_agent'
