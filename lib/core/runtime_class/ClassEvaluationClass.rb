class ClassEvaluationClass < ClassName
  
  def initialize
    super 
  end

  def write(context=nil)
    return 'ClassEvaluation'
  end

  def copy
    return ClassEvaluationClass.new
  end

  def value
    return ClassEvaluation
  end  
  
end