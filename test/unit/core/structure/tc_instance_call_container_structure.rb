require 'required'
require 'test/unit'

class TestInstanceCallContainerStructure < Test::Unit::TestCase
  
  def setup
    
    # Create an array of variables to allow <runtime_method_var>.push(<statement_var>)
    @runtime_method_var = RuntimeMethod.new(MethodUsage.new).to_var
    @statement_var = Statement.new().to_var
    @statement_and_runtime_method_var = [
      @runtime_method_var,
      @statement_var
    ]
    
  end
  
  def teardown
    System.reset
  end  
  
  def test_statements
    
    # Chect that <runtime_method_var>.push(<statement_var>) can be created
    assert_equal(1,InstanceCallContainerStructure.new().statements(@statement_and_runtime_method_var).length)
    assert_equal(
      @runtime_method_var.write+'.push('+@statement_var.write+')',
      InstanceCallContainerStructure.new().statements(@statement_and_runtime_method_var).first.write
    )
    
    # Check that <runtime_method_var>.push(<statement_var>) changes uniq_id but retains old reference
    resulting_statement = InstanceCallContainerStructure.new().statements(@statement_and_runtime_method_var).first
    assert_equal(resulting_statement.first.subject.variable_id,@runtime_method_var.variable_id)
    #assert_not_equal(resulting_statement.first.subject.uniq_id,@runtime_method_var.uniq_id)
    assert(resulting_statement.first.subject.uniq_id_history.kind_of?(Array))
    #assert(resulting_statement.first.subject.uniq_id_history.any? {|x| x == @runtime_method_var.uniq_id})
    #assert_equal(1,resulting_statement.first.subject.uniq_id_history.length)    
    
  end
      
end