require 'required'
require 'test/unit'

class TestStatementGroup < Test::Unit::TestCase
  
  def setup
    
  end
  
  def teardown
System.reset
    RuntimeMethod.reset_global_id
  end  
  
  def test_find_all_required_runtime_methods
    
    # 1.  Find all the runtime methods in a statement group with two statements in
    #   a.  Create both statements and methods used in the statement group
    method_1 = RuntimeMethod.new(MethodUsage.new)
    method_2 = RuntimeMethod.new(MethodUsage.new)
    statement_1 = Statement.new(Unknown.new,Equal.new,DefCall.new(nil.to_var,method_1))
    statement_2 = Statement.new(Unknown.new,Equal.new,DefCall.new(nil.to_var,method_2))    
    
    #   b.  Create the statement group with the runtime methods and check that both
    #       runtime methods are retrieved.
    statement_group_1 = StatementGroup.new(statement_1,statement_2)
    assert_equal(2,statement_group_1.find_all_required_runtime_methods.length)
    statement_group_1.find_all_required_runtime_methods.each do |x|
      assert(x.kind_of?(RuntimeMethod))
    end
    
  end
  
  
end