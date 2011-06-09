class VariableDeclaration < Declaration
  
  attr_reader :class_name
  
  def initialize(class_name,*parameters)
    super(nil)
    
    raise StandardError.new('Expecting class name as a string but is a '+class_name.to_s) unless class_name.kind_of?(String)
    
    # The name of the class to be instantiated
    @class_name = class_name
    parameters.each do |x|
      raise StandardError.new('unexpect data type '+x.class.to_s) unless x.kind_of?(Declaration)
      self.push x
    end
  end
  
  def write
    l = @class_name.to_s+'.new('
    self.each do |x|
      l += x.write
      l += ', ' unless x.object_id == self.last.object_id
    end
    l += ')'
    return l
  end
  
  def copy
    return VariableDeclaration.new(@class_name,*self.collect {|x| x.copy})
  end
  
  # Returns the evaluated value of the current declaration.
  def evaluate
     CodeEvaluation.new.evaluate_code(self.write)
  end
  
  def has?(&block)
    self.each do |x|
      return true if block.call(x)
    end
    return false
  end      
  
  # This replaces a variable declaration with a scope value.  This will general
  # called on Statement VariableDeclarations that contain TheoryVariable declarations
  # e.g. Statement.new(Return.new(), TheoryVariable.new(9))
  #
  # It would then be supplied a hash {9=><#some_instance>}, this would then
  # be substituted into the statement variable declaration. 
  #  
  def replace_theory_variable_declarations!(mapping)
    self.each_with_index do |x,i|
      if x.kind_of?(VariableDeclaration) && x.class_name == 'TheoryVariable' && mapping.has_key?(x.first.value)
        self[i] = mapping[x.first.value].copy
      end
    end        
  end  
  
end