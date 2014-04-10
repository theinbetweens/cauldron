require 'rubygems'
require "bundler/setup"

require 'logger'
require 'yaml'
require 'ruby2ruby'
require 'ruby_parser'
#require 'ruby-debug'

require 'core/string'

require 'cauldron/pot'
require 'cauldron/terminal'
require 'cauldron/relationship'
require 'cauldron/if_relationship'
require 'cauldron/numeric_operator'
require 'cauldron/concat_operator'
require 'cauldron/array_reverse_operator'
require 'cauldron/hash_key_value_operator'