class StatementClass < ClassName
  
  def initialize
    super
  end
  
  def write(context=nil)
    return 'Statement'
  end  
  
  def copy
    return StatementClass.new
  end
  
  def value
    return Statement
  end
  
  # Returns an array of class methods call for Statement.  For example
  #
  # ClassMethodCallContainer.new(StatementClass.new,New.new(Unknown.new,Equal.new,x))
  #
  def class_method_calls(available=[])

    # NOTE: I could create a LiteralDeclarationDeclaration
    fixnum_declarations = available.select{|y| y.kind_of?(Literal)}.collect do |x|
      ClassMethodCallContainer.new(
        StatementClass.new,
        New.new,
        ClassMethodCallContainer.new(UnknownClass.new,New.new),
        ClassMethodCallContainer.new(EqualClass.new,New.new),
        InstanceCallContainer.new(x.to_declaration,ToDeclarationCall.new)
      )
    end
    
    # Create ClassMethodCallContainer.new(StatementClass.new,New.new(Unknown.new,Equal.new,InstanceCallContainer.new(unknown_var,StringLength)))
    # TODO  This uses UnknownVariable but we don't know if the UnknownVariable is a string or not
    available_unknown_variables = available.select_all {|x| x.kind_of?(UnknownVariable)}
    string_length_statement = available_unknown_variables.collect do |x|
      ClassMethodCallContainer.new(
        StatementClass.new,
        New.new,
        ClassMethodCallContainer.new(UnknownClass.new,New.new),
        ClassMethodCallContainer.new(EqualClass.new,New.new),
        #InstanceCallContainer.new(x,StringLength.new)
        ClassMethodCallContainer.new(InstanceCallContainerClass.new(),New.new,x, ClassMethodCallContainer.new(StringLengthClass.new,New.new))
      )
    end 
    
    return fixnum_declarations+string_length_statement
  end  
  
end