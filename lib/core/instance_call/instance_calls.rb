class Value < InstanceCall
  
  def initialize
    super
  end
  
  def write
    return '.value'
  end
  
  def copy
    # TODO  Move this to the InstanceCall class
    return Value.new
  end
  
end 

class AllPass < InstanceCall
  
  def initialize
    super
  end
  
  def write
    return '.all_pass?'
  end
  
  def copy
    return AllPass.new
  end
  
end

class Realise < InstanceCall
  
  def initialize
    super
  end 
  
  def write
    return '.realise2'
  end
  
  def copy
    return Realise.new
  end
  
end

class Pass < InstanceCall
  
  def write
    return '.pass?'
  end
  
  def copy
    return Pass.new
  end
  
  def accessor?
    return false
  end
  
end

class Run < InstanceCall
  
  def write
    return '.run'
  end
  
  def copy
    return Run.new
  end
  
end

class KindOf < InstanceCall
  
  def write
    return '.kind_of?'
  end
  
  def copy
    return KindOf.new
  end
  
  def param_count
    return 1
  end
  
  def possible_params
    return %w{String Fixnum CTestCase}
  end
  
end

class HistoryCall < InstanceCall
  
  def write
    return '.history'
  end
  
  def copy
    return HistoryCall.new
  end
  
end

class History2Call < InstanceCall
  
  def write
    return '.history2'
  end
  
  def copy
    return History2Call.new
  end
  
end

class Any < InstanceCall
  
  def write
    return '.any?'
  end
  
  def copy
    return Any.new
  end
  
end

class Include < InstanceCall
  
  def write
    return '.include?'
  end
  
  def copy
    return Include.new
  end
  
end

class StatementID < InstanceCall
  
  def write
    return '.statement_id'
  end
  
end

class Last < InstanceCall
  
  def write
    return '.last'
  end

end

class Select < InstanceCall
  
  def write
    return '.select'
  end

end
