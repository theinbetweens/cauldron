class If
  include Code 
  
  def initialize
    super  
  end
  
  def write(tab=0)
    return ("\t"*tab)+'if'
  end  
  
  def copy
    return If.new
  end
  
  def creation
    return 'If.new'
  end    
  
end

# TODO  I need to go over my "if statement" construction

#  t = OpenStatement.new(
#    Statement.new(
#      If.new,test_cases[0][:params][0], Equivalent.new, test_cases[0][:output]
#    )
#  )
