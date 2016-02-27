require 'rubygems'
require "bundler/setup"

require 'logger'
require 'yaml'
require 'ruby2ruby'
require 'ruby_parser'
require 'sorcerer'

require 'pry_tester'
require 'pry'

# http://stackoverflow.com/questions/18732338/trying-to-require-active-support-in-gem
require "active_support/all"

require 'tree'

require 'core/string'

require 'cauldron/pot'
require 'cauldron/caret'
require 'cauldron/example'
require 'cauldron/example_set'
require 'cauldron/terminal'
require 'cauldron/scope'
require 'cauldron/histories'
require 'cauldron/history'
require 'cauldron/tracer'
require 'cauldron/relationship'
require 'cauldron/if_relationship'
require 'cauldron/operator'
require 'cauldron/statement_generator'
require 'cauldron/dynamic_operator'
require 'cauldron/operator/numeric_operator'
require 'cauldron/operator/concat_operator'
require 'cauldron/operator/array_reverse_operator'
require 'cauldron/operator/hash_key_value_operator'
require 'cauldron/operator/string_asterisk_operator'
require 'cauldron/operator/array_collect'
require 'cauldron/operator/to_s_operator'
require 'cauldron/operator/var_collect_operator'
require 'cauldron/dynamic_operator_module'

require 'cauldron/solution/one'
require 'cauldron/actualized_composite'
require 'cauldron/solution/composite'
require 'cauldron/builder'