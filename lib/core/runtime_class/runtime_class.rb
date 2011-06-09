class TheoryStatementClass < ClassName
  
  def initialize
    super
  end
  
  def write(context=nil)
    return 'TheoryStatement'
  end  
  
  def copy
    return TheoryStatementClass.new
  end
  
  def value
    return TheoryStatement
  end
  
  # TODO  I'm not sure if this is needed
  def declaration_statement
    return ClassMethodCallContainer.new(TheoryStatementClass.new,New.new)
  end  
  
  def class_method_calls(available=[])
  end  
  
end

class ParserClass < ClassName
  
  def initialize
    super
  end
  
  def write(context=nil)
    return 'Parser'
  end  
  
  def copy
    return ParserClass.new
  end
  
  def value
    return parser
  end
  
  # TODO  I'm not sure if this is needed
  def declaration_statement
    return ClassMethodCallContainer.new(ParserClass.new,New.new)
  end  
  
  def class_method_calls(available=[])
  end  
  
end

class AdditionClass < ClassName
  
  def initialize
    super
  end
  
  def write(context=nil)
    return 'Addition'
  end  
  
  def copy
    return AdditionClass.new
  end
  
  def value
    return Addition.class
  end
  
  def declaration_statement
    return ClassMethodCallContainer.new(AdditionClass.new,New.new)
  end  
  
  def class_method_calls(available=[])
  end  
  
end

class CTestCaseClass < ClassName
  
  def initialize
    super
  end
  
  def write(context=nil)
    return 'CTestCase'
  end  
  
  def value
    return CTestCase.class
  end
  
  def declaration_statement
    return ClassMethodCallContainer.new(CTestCaseClass.new,New.new)
  end    
  
end

class FixnumClass < ClassName
  
  def initialize
    super
  end
  
  def write(context=nil)
    return 'Fixnum'
  end  
  
  def value
    return CTestCase.class
  end
  
  def declaration_statement
    return ClassMethodCallContainer.new(FixnumClass.new,New.new)
  end    
  
end

