$LOAD_PATH.unshift File.expand_path('../lib',__FILE__)

require 'cauldron'
require 'ruby_debug'
require 'yaml'


# unified_chain = Cauldron::Util::Saver.load(1)
# 
# puts unified_chain.describe
# puts unified_chain.complete?
# 
# puts 'Working'

# === Pry ===
# Pry::Code.new(@str).length 


# unified_chain = Cauldron::Util::Saver.load(298)
# runtime_method = Cauldron::Util::Saver.load(31)
# test_cases  = Cauldron::Util::Saver.load(32)
# 
# puts unified_chain.describe

# gem install ruby_parser
# RubyParser.new.parse "1+1"

# gem 'sexp_processor', '~> 4.4.3'

#unified_chain.valid_mapping_permutations(runtime_method,test_cases)

string = <<-EOF
  blah blah
  blah blah
  EOF
puts string

module YAML

  require 'rspec'

  def YAML.load_file( filepath )
    File.open( filepath ) do |f|
      f = double(:file)
      load( double(:file) )
    end
  end

end

details = YAML.load_file("loaded_file.yaml")