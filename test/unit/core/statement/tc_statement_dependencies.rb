
require 'required'
require 'test/unit'

class TestStatementDependencies < Test::Unit::TestCase
  
  def setup
    
    # 
    # var_a = 'Wally'.chop
    # var_b = var_a.length
    # var_c = var_a.chop
    
    # Create some statements with dependencies
    @wally = Literal.new('Wally')
    @chopped_wally = Unknown.new
    @chop_wally = Statement.new(@chopped_wally,Equal.new,InstanceCallContainer.new(@wally,Chop.new))
    @chopped_length = Unknown.new
    @chop_length = Statement.new(@chopped_length,Equal.new,InstanceCallContainer.new(@chopped_wally,StringLength.new))
    @wall = Unknown.new
    @statement_c = Statement.new(@wall,Equal.new,InstanceCallContainer.new(@chopped_wally,Chop.new))
    @hermot = Literal.new('Hermot')
    @hermot_var = Unknown.new
    @declared_hermot = Statement.new(@hermot_var,Equal.new,@hermot)
    @hermo_wall = Unknown.new
    @hermo_wall_statement = Statement.new(@hermo_wall,Equal.new,InstanceCallContainer.new(@hermot_var,Chop.new),Addition.new,InstanceCallContainer.new(@chopped_wally,Chop.new))
    
    # This statement uses variables that haven't been declared in a statement
    @bad_statement = Statement.new(Unknown.new,Equal.new,InstanceCallContainer.new(StringVariable.new('badboy'),Chop.new))
    
    # Chopping wall
    @wal = Unknown.new
    @statement_d = Statement.new(@wal,Equal.new,InstanceCallContainer.new(@wall,Chop.new))
    
    # Create a simple set of statement dependencies that use params
    # var_a = MethodUsage.new
    # var_b = RuntimeMethod.new(var_a)
    @dependency_set_1 = StatementDependencies.new
    @var_a = Unknown.new
    @var_b = Unknown.new
    @statement_a = Statement.new(@var_a,Equal.new,ClassMethodCallContainer.new(MethodUsageClass.new,New.new))
    @statement_b = Statement.new(@var_b,Equal.new,ClassMethodCallContainer.new(RuntimeMethodClass.new,New.new,@var_a))
    @dependency_set_1.push(@statement_a)
    @dependency_set_1.push(@statement_b)      
    
    
  end

  def teardown
    System.reset
  end   
  
  def test_push
    
    # Check statements can be added 
    statement_depenencies = StatementDependencies.new(@chop_wally)
    assert_equal(1,statement_depenencies.length)
    
    # Check pushing new statements
    statement_depenencies.push(@chop_length)
    assert_equal(2,statement_depenencies.length)
    
    # Check that an error is thrown if the statement dependencies can't be found
    assert_raises(StandardError){statement_depenencies.push(@bad_statement)}    
    
    # Here we are check depenceys are found for statements with multiple variables in
        
    
  end
  
  def test_dependencies_for
    
    statement_depenencies = StatementDependencies.new()  
    # hermot = 'Hermot'
    statement_depenencies.push(@declared_hermot)
    
    # This statement shouldn't have any depenencies
    assert_equal(1,statement_depenencies.dependencies_for(@declared_hermot.statement_id).length)  
    
    # Add a statement dependent on the first statement
    # chopped_wally = 'Wally'.chop
    statement_depenencies.push(@chop_wally)
    assert_equal(1,statement_depenencies.dependencies_for(@chop_wally.statement_id).length)
    statement_chop_chop_wally = Statement.new(Unknown.new,Equal.new,InstanceCallContainer.new(@chopped_wally,Chop.new))
    statement_depenencies.push(statement_chop_chop_wally)
    assert_equal(2,statement_depenencies.dependencies_for(statement_chop_chop_wally.statement_id).length)
     
    # Now add a string+string statement that uses the above statement
    statement_depenencies.push(@hermo_wall_statement)
    assert_equal(3,statement_depenencies.dependencies_for(@hermo_wall_statement.statement_id).length)
    
    assert_equal(1,@dependency_set_1.dependencies_for(@statement_a.statement_id).length)
    assert_equal(@statement_a.statement_id,@dependency_set_1.dependencies_for(@statement_a.statement_id).first)    
    assert_equal(2,@dependency_set_1.dependencies_for(@statement_b.statement_id).length)    
    
    # Create the statement with dependencies
    statement_depenencies = StatementDependencies.new(@chop_wally,@chop_length,@statement_c)
    
    # Find the needed variables for the statements
    assert_equal(1,@chop_length.not_declared_variables.length)
    
    # First statement doesn't have any dependecies
    assert_equal(1,statement_depenencies.dependencies_for(@chop_wally.statement_id).length)        
    
    # The secound statement has one dependency
    assert_equal(2,statement_depenencies.dependencies_for(@chop_length.statement_id).length)        
    assert_equal(@chop_wally.statement_id,statement_depenencies.dependencies_for(@chop_length.statement_id).first)        
    
    # The third statement also only has one dependency
    assert_equal(@chop_wally.statement_id,statement_depenencies.dependencies_for(@statement_c.statement_id).first)        
    
    # Add a fourth statement with 2 dependencies 'Wally' then 'Wall'
    statement_depenencies.push(@statement_d)
    assert_equal(3,statement_depenencies.dependencies_for(@statement_d.statement_id).length)            

    # Check that an error is raised when looking for depencies for a variable that doesn't exist
    assert_raises(StandardError){statement_depenencies.dependencies_for(@bad_statement.statement_id)}    
    
  end

  def test_find_dependencies_for
     assert_equal(0,@dependency_set_1.find_dependencies_for(@statement_a).length)
     assert_equal(1,@dependency_set_1.find_dependencies_for(@statement_b).length) 
     
    #  Check that dependies are found for modified statements
    #   var_a = 8
    #   var_b = []
    #   var_b.push(9)
    #   var_b.push(10)
    statement_a_1 = Statement.new(Unknown.new,Equal.new,8.to_literal)
    statement_a_2 = Statement.new(Unknown.new,Equal.new,[].to_literal)    
    statement_a_3 = Statement.new(InstanceCallContainer.new(statement_a_2.first.copy,Push.new,9.to_literal))
    statement_a_4 = Statement.new(InstanceCallContainer.new(statement_a_3.first.subject.copy,Push.new,10.to_literal))
    runtime_a = RuntimeMethod.new(MethodUsage.new)
    runtime_a.push(statement_a_1)
    runtime_a.push(statement_a_2)
    runtime_a.push(statement_a_3)
    runtime_a.push(statement_a_4)
    
    # Realise the method and add each of statements
    assert_nothing_raised(){runtime_a.realise2(ParametersContainer.new)}
    
     
  end

end