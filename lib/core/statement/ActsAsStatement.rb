# This module is shared between the Statement and BlockStatement classes.  It 
# ensures that both those classes have a statement id and a structure type.
#
module ActsAsStatement
  
  # Returns true if the statement (treated as an array) has all the
  # same classes as the array supplied.
  # 
  # @param  classes     An array of classes that this statement is 
  #                     compared to.
  #
  def classes_match?(*classes)
    return false unless classes.length == self.length
    @nodes.zip(classes) do |x,y|  
      return false unless x.instance_of?(y)
    end
    return true
  end
  
end