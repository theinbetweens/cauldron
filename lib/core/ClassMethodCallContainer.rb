# 
# FixnumVariable.new(8)
#
class ClassMethodCallContainer < CallContainer
  attr_reader :method_call, :parameters
  
  def initialize(class_name,method_call,*parameters)
    
    # Check the type for the class name
    raise StandardError.new('Unexpected data type '+class_name.class.to_s) unless class_name.kind_of?(ClassName)
    @class_name = class_name
    
    super(class_name,method_call,*parameters)
  end
  
  def class_name
    return @subject
  end
  
  def copy
    return ClassMethodCallContainer.new(@subject.copy,@method_call.copy,*@parameters.collect {|x| x.copy})
  end
  
  # This method is used during tracking to print a general description of what
  # the instance call is doing. e.g. MethodUsage.new.
  #
  def to_literal_string
    return @class_name.write+'.'+@method_call.to_literal_string
  end  
  
  # TODO  Write tests
  # Returns true if the supplied argument is the same class, has the equivalent subjects
  # and parameters. 
  #
  def equivalent?(to)
    return false unless self.class == to.class
    return false unless @class_name.class == to.class_name.class
    return false unless @method_call.class == to.method_call.class
    @parameters.each_with_index do |x,i|
      return false unless x.equivalent?(to.parameters[i])
    end
    return true 
  end
  
  def replace_variables_alt!(map)
    @parameters.each_with_index do |x,i|
      if x.kind_of?(TheoryVariable)
        map.each do |key,value|
          if x.theory_variable_id == key.theory_variable_id
            @parameters[i] = value
          end
        end
      else
        x.replace_variables_alt!(map)
      end
    end  
  end
 
end