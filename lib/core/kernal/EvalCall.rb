class EvalCall
  
  def initialize(content)
    @content = content
  end
  
  def write
    return 'eval('+@content+')'  
  end
  
  def copy
    return EvalCall.new(@content.dup)
  end
  
end