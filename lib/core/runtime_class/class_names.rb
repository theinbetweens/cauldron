class EquivalentClass < ClassName
  
  def initialize
    super
  end
  
  def write(context=nil)
    return 'Equivalent'
  end  
  
end

class OpenStatementClass < ClassName
  
  def initialize
    super
  end
  
  def write(context=nil)
    return 'OpenStatement'
  end  
  
end

class BlockStatementClass < ClassName
  
  def initialize
    super
  end
  
  def write(tab=0)
    return 'BlockStatement'
  end  
  
end

class ContainerClass < ClassName
  
  def initialize
    super
  end
  
  def write(tab=0)
    return 'Container'
  end  
  
end

class SubtractClass < ClassName
  
  def initialize
    super
  end
  
  def write(tab=0)
    return 'Subtract'
  end  
  
end

class TimesClass < ClassName
  
  def initialize
    super
  end
  
  def write(tab=0)
    return 'Times'
  end  
  
end

class ChopClass < ClassName
  
  def initialize
    super
  end
  
  def write(tab=0)
    return 'Chop'
  end  
  
end

class IfClass < ClassName
  
  def initialize
    super
  end
  
  def write(tab=0)
    return 'If'
  end  
  
end