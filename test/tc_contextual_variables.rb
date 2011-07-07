# This meant to test that the variables requirements change to reflect
# the context they are accessed.
#

# TODO  This can go!

require 'required'
require 'test/unit'

class TestContextualVariable < Test::Unit::TestCase
  
  def setup
    
  end
  
  def teardown
    System.reset
    RuntimeMethod.reset_global_id
  end  
  
end