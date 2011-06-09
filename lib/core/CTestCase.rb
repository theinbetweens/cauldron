# This is an individual test case that has an input an output.  It is essentially
# just a hash but I've created a new class for it just for the convenience of using
# the .kind_of? method in theory chains.     
#
# TODO  Don't like extending core datatypes
class CTestCase < Hash
 
  # TODO  Should be able pass the hash directly or usea variable to contain the hash
  def initialize(inputs=nil,output=nil)
    super()
    self[:params] = inputs
    self[:output] = output
  end
  
  def copy    
    return Marshal.load(Marshal.dump(self))    
  end  
  
  def cauldron_method_calls
    results = self.collect do |key,value|
      '[:'+key.to_s+']'
    end
    results << '.kind_of?'
    return results
  end

end