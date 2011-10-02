$LOAD_PATH.unshift File.expand_path('../lib',__FILE__)

require 'cauldron'

# unified_chain = Cauldron::Util::Saver.load(1)
# 
# puts unified_chain.describe
# puts unified_chain.complete?
# 
# puts 'Working'


object = Cauldron::Util::Saver.load(2)
puts object.describe
object.realise2(ParametersContainer.new)
