require 'rubygems'
require "bundler/setup"

require 'logger'
require 'yaml'
require 'ruby2ruby'
require 'ruby_parser'
require 'sorcerer'

require 'core/string'

require 'cauldron/pot'
require 'cauldron/terminal'
require 'cauldron/relationship'
require 'cauldron/if_relationship'
require 'cauldron/numeric_operator'
require 'cauldron/concat_operator'
require 'cauldron/array_reverse_operator'
require 'cauldron/hash_key_value_operator'
require 'cauldron/operator/string_asterisk_operator'
require 'cauldron/operator/array_collect'

require 'cauldron/solution/one'
require 'cauldron/solution/composite'