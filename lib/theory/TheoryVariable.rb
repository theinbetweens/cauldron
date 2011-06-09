class TheoryVariable
  include Variable
  include Token
  
  attr_reader :theory_variable_id
  # colours http://forums.opensuse.org/archives/sls-archives/archives-suse-linux/archives-desktop-environments/379032-how-can-i-change-font-color-my-terminal.html
  RED = "\033[31m"
  GREEN = "\033[32m"
  YELLOW = "\033[33m"
  TURQUOISE = "\033[34m"
  VIOLET = "\033[35m"
  BLUE = "\033[36m"
  NORMAL = "\033[m"
  
  def initialize(theory_variable_id)
    @theory_variable_id = theory_variable_id
  end
  
  def write
    return "var#{@theory_variable_id}"
  end
  
  def describe
    return TheoryVariable.variable_colour(@theory_variable_id)+"var#{@theory_variable_id}"+NORMAL    
  end
  
  def copy
    return TheoryVariable.new(@theory_variable_id.copy)    
  end
  
  def to_declaration
    return VariableDeclaration.new('TheoryVariable',Literal.new(@theory_variable_id).to_declaration)
  end
  
  def eql?(obj)
    @theory_variable_id == obj.theory_variable_id     
  end
  
  def hash
    @theory_variable_id
  end

  # Returns the preset colour for that particular id for easier
  # tracking. 
  #
  def self.variable_colour(theory_variable_id)
    case theory_variable_id
      when 0
        return RED
      when 1
        return GREEN
      when 2
        return YELLOW
      when 3
        return TURQUOISE  
      when 4
        return VIOLET
    else
        return BLUE
    end
  end
    
end