require 'required'
require 'test/unit'

class TestStep < Test::Unit::TestCase
  
  def setup
    #   "variables"=>[
    #     {"id"=>3, "value"=>"Grim Fandang", "abs_id"=>-606538658, :uniq_id=>3}, 
    #     {"id"=>1, "value"=>"Grim Fandango", "abs_id"=>-606538498, :uniq_id=>2}
    #   ], 
    #   "line"=>1, 
    #   "statement_id"=>625, 
    #   "action"=>"var='Grim Fandango'.chop"}
    @basic_step = Step.new(
      1,
      625,
      [ {"id"=>3, "value"=>"Grim Fandang", "abs_id"=>-606538658, :uniq_id=>3}, 
        {"id"=>1, "value"=>"Grim Fandango", "abs_id"=>-606538498, :uniq_id=>2}],
      "var='Grim Fandango'.chop"
    )            
            
  end
  
  def teardown
    System.reset
  end  
  
  def test_initialize
    assert_nothing_raised(){
      basic_step = Step.new(
        1,
        625,
        [ {"id"=>3, "value"=>"Grim Fandang", "abs_id"=>-606538658, :uniq_id=>3}, 
          {"id"=>1, "value"=>"Grim Fandango", "abs_id"=>-606538498, :uniq_id=>2}],
        "var='Grim Fandango'.chop"
      )     
    }
  end
  
  def test_find_data_for_variable

  end

  def test_to_var
    assert_nothing_raised(){@basic_step.to_var}
    assert_kind_of(StepVariable,@basic_step.to_var)
  end
       
  def test_copy
    assert_nothing_raised(){@basic_step.copy}
    assert_equal(
      @basic_step['line'],
      @basic_step.copy['line']
    )
    assert_equal(
      @basic_step['variables'][0]['abs_id'],
      @basic_step.copy['variables'][0]['abs_id']
    )
    assert_equal(
      @basic_step['variables'][1]['abs_id'],
      @basic_step.copy['variables'][1]['abs_id']
    )        
  end

end