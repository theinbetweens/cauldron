class ArrayReverseOperator

  #Arra

  def initialize
  end  

  # Matching in 
  def successful?(input,output)
    # input.length.each do |i|
    # does input[0] == output[input.length-0]
    # does input[1] == output[input.length-1]
    # does input[3] == output[input.length-3]
    # end
    # in this case x.reverse will work
  end

  # 1. Only has one argument value
  # 2. Argument is an array value
  # 3. Response is an array 
  def self.viable?(arguments,output)
    return false unless arguments.length == 1
    return false unless arguments.all? { |x| x.kind_of?(Array) }
    return false unless output.kind_of?(Array)
    true
  end

  # def describe - 
  # should be able to describe the x.object_id moving to the different locations

end