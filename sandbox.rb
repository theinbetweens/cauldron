$LOAD_PATH.unshift File.expand_path('../lib',__FILE__)

require 'cauldron'

# unified_chain = Cauldron::Util::Saver.load(1)
# 
# puts unified_chain.describe
# puts unified_chain.complete?
# 
# puts 'Working'


unified_chain = Cauldron::Util::Saver.load(33)
runtime_method = Cauldron::Util::Saver.load(31)
test_cases  = Cauldron::Util::Saver.load(32)

puts unified_chain.describe


#unified_chain.valid_mapping_permutations(runtime_method,test_cases)

  

