require 'required'
require 'test/unit'

class TestInstanceCallContainer < Test::Unit::TestCase
  
  def setup
      
  end
  
  def teardown
    System.reset
    RuntimeMethod.reset_global_id    
  end
  
  def test_equivalent
    
    # Create a push statement and confirm they are captured as equivalent
    instance_call_container_a = InstanceCallContainer.new(RuntimeMethod.new(MethodUsage.new).to_var,Push.new,Statement.new.to_var)
    assert(true,instance_call_container_a.equivalent?(instance_call_container_a.copy))
    
  end
  
  def test_subst!
    
    # Test that variables are replaced in the instance call
    # 'warren'.length -> 'marc'.length
    warren = 'warren'.to_var
    new_var_length = InstanceCallContainer.new(warren,StringLength.new)
    marc = 'marc'.to_var
    assert_equal(warren.uniq_id,new_var_length.subject.uniq_id)
    new_var_length.subst!(marc) {|x| x.uniq_id == warren.uniq_id}
    assert_equal(marc.uniq_id,new_var_length.subject.uniq_id)
    assert_not_equal(warren.uniq_id,new_var_length.subject.uniq_id)
    
    # Test the paramters are properly replaced
    # [].push('dragon') -> [].push('unicorn')
    dragon = 'dragon'.to_var
    unicorn = 'unicorn'.to_var
    pushing_call = InstanceCallContainer.new([].to_var,Push.new,dragon)
    assert_equal(pushing_call.parameters.last.uniq_id,dragon.uniq_id)
    pushing_call.subst!(unicorn){|x| x.uniq_id == dragon.uniq_id}
    assert_not_equal(pushing_call.parameters.last.uniq_id,dragon.uniq_id)   
    assert_equal(pushing_call.parameters.last.uniq_id,unicorn.uniq_id)       
        
  end
  
  def test_select_all
    assert_equal(
      2,
      StringToTheory.run(
        "var1.realise2(var3).params[0].value.length"
      ).select_all {|x| x.kind_of?(TheoryVariable)}.length
    )
  end
  
  def test_contains
    assert_equal(
      true,
      Parser.run('var1.push(8)').kind_of?(InstanceCallContainer)
    )
    assert_equal(
      true,
      Parser.run('var1.push(8)').contains? {|x| x.kind_of?(Unknown)}
    )
    assert_equal(
      true,
      Parser.run('var1.push(8)').contains? {|x| x.kind_of?(Push)}
    )
    assert_equal(
      true,
      Parser.run('var1.push(8)').contains? {|x| x.kind_of?(Literal)}
    )     
  end
  
  def test_equivalent
    assert_equal(
      true,
      Parser.run('var1.push(8)').equivalent?(Parser.run('var1.push(8)'))
    )
    assert_equal(
      true,
      Parser.run('var2.push(8)').equivalent?(Parser.run('var1.push(8)'))
    )
    assert_equal(
      true,
      Parser.run('var2.push(var8)').equivalent?(Parser.run('var1.push(var9)'))
    )
    assert_equal(
      false,
      Parser.run('var2.push(var8)').equivalent?(Parser.run('var1.push(var9,var7)'))
    )    
  end
end