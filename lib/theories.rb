
# TODO  Not so keen on loading each theory in super - rather do it in the methods
#        it is needed.

# TODO Allot of this functionalty should be moved to the rake tasks  

module ContainsTheories

  def setup
    @theory_1 = Theory.load_theory(1)
    @theory_2 = Theory.load_theory(2)
    @theory_3 = Theory.load_theory(3)    
  end
  
  def load_theory_implementation(implementation_id)
    directory_path = $LOC+File.join('test','fixtures','theory_implementations',implementation_id.to_s)
    raise StandardError.new("Theory fixture #{implementation_id} does not exist") unless(File.exists?(directory_path))
    dump_file = File.open(File.join(directory_path,'dump'),'r')
    return Marshal.load(dump_file.read)
  end
  
  def create_theory_implementation
    
    theory = Theory.load_theory(6)
    potential_values = [
        Parser.run('test_cases[0][:params][0]'),
        Parser.run('test_cases[0][:params]'),
        Parser.run('test_cases[0][:output]'),
        Parser.run('test_cases[0]'),
        Parser.run('test_cases'),
        Parser.run('runtime_method')
    ]
    results = theory.rewrite_permutations(potential_values)
    # NOTE: Rember use grep -A and -B to match particular cases
    implemented_theory = results[332]
    return implemented_theory
    
  end
  
  def save_theory_implementation(implementation_id,theory_id,implementation=nil)
    StandardLogger.instance.warning("Caution: Creating new theory implementation #{implementation_id}")
    directory_path = $LOC+File.join('test','fixtures','theory_implementations',implementation_id.to_s)
    if(File.exists?(directory_path))
      StandardLogger.instance.warning("Theory Implementation ficture already exists #{theory_id} -cancelling")
      return
    else
      FileUtils.mkdir_p(directory_path)
    end 
    
    if implementation.nil? then implementation = create_theory_implementation end
    
    desc_file = File.open(File.join(directory_path,'desc.txt'),'w')
    desc_file << implementation.describe
    desc_file.close    
    
    dump_file = File.open(File.join(directory_path,'dump'),'w')
    data = Marshal.dump(implementation)
    dump_file << data
    dump_file.close
    
    dump_file = File.open(File.join(directory_path,'theory_id'),'w')
    dump_file << theory_id.to_s
    dump_file.close    
    
  end
  
  def load_implementation_result(result_id)
    directory_path = $LOC+File.join('test','fixtures','implementation_results',result_id.to_s)
    raise StandardError.new("ImplementationResult fixture #{result_id} does not exist") unless(File.exists?(directory_path))
    dump_file = File.open(File.join(directory_path,'dump'),'r')
    return Marshal.load(dump_file)    
  end
  
  # This method is used on to create a theory fixture for use in the test
  def create_theory
    
    theory_id = "16"
 
    StandardLogger.instance.warning("NOTE: Creating new theory fixture #{theory_id.to_s}")
    # Does a directory for this theory fixture already exist.
    directory_path = $LOC+File.join('test','fixtures','theories',theory_id.to_s)
    if(File.exists?(directory_path))
      StandardLogger.instance.warning("Theory ficture already exists #{theory_id.to_s} -cancelling")
      return
    else
      
      # Create the directory
      FileUtils.mkdir_p(directory_path)
      
    end
    
    # This is just updated here - nothing fancy
    declaration = %q!
    dependent_one = TheoryDependent.new(
      StringToTheory.run(
        "if(var1.kind_of?(RuntimeMethod))\nreturn true\nend"
      )
    )     
    dependent_two = TheoryDependent.new(
      StringToTheory.run(
        "if(var3[var4].kind_of?(CTestCase))\nreturn true\nend"
      )
    )     
    action = TheoryAction.new(
      TheoryStatement.new(
        StringToTheory.run(
          'BlockStatement.new(Statement.new(InstanceCallContainer.new(Container.new(InstanceCallContainer.new(var1.params[var2],StringLength.new),Subtract.new,1),Times.new)))'
        )
      ),
      StringToTheory.run('var1.statement_id')
    )
    result_one = TheoryResult.new(
      StringToTheory.run(
        "if(var1.history2(var3[var4]).select {|x| x['statement_id'] == var3.last.statement_id} == var3[var4][:params][var2].length-1)\nreturn true\nend"
      )
    )
      Theory.new(
        [dependent_one,dependent_two],
        action,
        [result_one]
      )    
    !
    
    # Save the declaration (incase the theory needs modified
    declaration_file = File.open(File.join(directory_path,'declaration.txt'),'w+')
    declaration_file << declaration
    declaration_file.close    
    
    theory = eval declaration
    data = Marshal.dump(theory)

    # TODO  Shouldn't include colours for this description
    desc_file = File.open(File.join(directory_path,'desc'),'w+')
    desc_file << theory.describe
    desc_file.close
    
    dump_file = File.open(File.join(directory_path,'dump'),'w+')
    dump_file << data
    dump_file.close

  end  

end