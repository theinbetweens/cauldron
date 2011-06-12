# http://rake.rubyforge.org/
# http://rake.rubyforge.org/files/doc/rakefile_rdoc.html

# TODO  Need a test for the rake tasks as well

namespace :cauldren do
  
  namespace :implementations do
    
    desc "Re-build the theory implementations"
    task :rebuild do 
    
      file_list = FileList.new('test/fixtures/theory_implementations/*')
      file_list.each do |x|
        implementation_id = x.match(/\d+$/)[0].to_i
    
        directory_path = $LOC+File.join('test','fixtures','theories',theory_id.to_s)
        
      end                
    
      # TODO  The current approach to saving the implementations - I'd like to be able
      #       to right the declarations to file.
      
      puts 'Does not do anything'
      
    end
    
    desc 'Creates a new theory implementation'
    task :create do
      implementation_id = 0
      
      StandardLogger.instance.warning("Caution: Creating new theory implementation #{implementation_id}")
      directory_path = $LOC+File.join('test','fixtures','theory_implementations',implementation_id.to_s)
      if(File.exists?(directory_path))
        StandardLogger.instance.warning("Theory Implementation ficture already exists #{implementation_id} -cancelling")
        exit
      else
        FileUtils.mkdir_p(directory_path)
      end       

      # This is just updated here - nothing fancy
      declaration = %q!
        theory = Theory.load_theory(1)
        potential_values = [
            Parser.run('0'),
            Parser.run('test_cases'),
            Parser.run('runtime_method')
        ]
        results = theory.rewrite_permutations(potential_values)
        # NOTE: Rember use grep -A and -B to match particular cases
        results[5]         
      !     
      theory_implementation = eval declaration
      
      # Save the declaration (incase the theory needs modified
      declaration_file = File.open(File.join(directory_path,'declaration.txt'),'w+')
      declaration_file << declaration
      declaration_file.close     
      
      dump_file = File.open(File.join(directory_path,'dump'),'w')
      data = Marshal.dump(theory_implementation)
      dump_file << data
      dump_file.close      
      
    end
    
    namespace :results do
      
      desc "Creates a new theory result implementation with the supplied id"
      task :create, :arg1 do |t,args|
        
        # Create the directory to save the implementation result
        directory_path = File.join('test','fixtures','implementation_results',args[:arg1])
        if(File.exists?(directory_path))
          StandardLogger.instance.warning("Implementation Result already exists #{args[:arg1]} -cancelling")
          return
        else
          FileUtils.mkdir_p(directory_path)
        end
        
        declaration = 
        %q!
          TheoryResult.new(Parser.run("if(runtime_method.all_pass?(test_cases))\nreturn true\nend"))
        !
        
        # Save the declaration (incase it needs rebuilt)
        declaration_file = File.open(File.join(directory_path,'declaration.txt'),'w+')
        declaration_file << declaration
        declaration_file.close 
        
        result = eval declaration
        data = Marshal.dump(result)
        
        dump_file = File.open(File.join(directory_path,'dump'),'w+')
        dump_file << data
        dump_file.close        
        
      end
      
    end
    
  end
  
  namespace :chain do
    
    desc "Create a new initial chain"
    task :create, :chain_id do |task,args| 
      
      # Create the directory to save the initial chains into 
      directory_path = $LOC+File.join('test','fixtures','chains',args[:chain_id])
      if(File.exists?(directory_path))
        StandardLogger.instance.warning("A chain with the id #{args[:chain_id]} already exists")
        return
      else
        FileUtils.mkdir_p(directory_path)
      end      
      
      # Create the declaration that creates the chain
      declaration = 
      %q!
        runtime_method = RuntimeMethod.new(MethodUsage.new(MethodParameter.new))
        sparky = CTestCase.new
        sparky[:params] = ['sparky']
        sparky[:output] = 6
        kel = CTestCase.new
        kel[:params] = ['kel']
        kel[:output] = 3
        test_cases = [
          sparky,kel
        ]    
        finish = Parser.run("if(runtime_method.all_pass?(test_cases))\nreturn true\nend")
        
        # Generate the head theory - this is the starting point and doesn't have any dependents
        accessors, mapping = TheoryGenerator.new.generate_accessors_and_mapping(test_cases,runtime_method,7,0)
        
        # * Generate all the possible results of this runtime method
        theory_results = TheoryGenerator.new.get_theory_results(accessors)
        
        # * Create the actual head theory
        head_theory = Theory.new([],nil,theory_results,runtime_method.copy)        
    
        intial_chain = Chain.new
        intial_chain.form_chain(head_theory,finish,mapping)
        intial_chain
      !      
      
      # Save the declaration (incase it needs rebuilt)
      declaration_file = File.open(File.join(directory_path,'declaration.txt'),'w+')
      declaration_file << declaration
      declaration_file.close 
      
      result = eval declaration
      data = Marshal.dump(result)
      
      dump_file = File.open(File.join(directory_path,'dump'),'w+')
      dump_file << data
      dump_file.close            
      
    end
    
    desc "Load the specified chain"
    task :load_chain, :chain_id do |task,args|
    
      # http://stackoverflow.com/questions/825748/how-do-i-pass-command-line-arguments-to-a-rake-task
      directory_path = $LOC+File.join('test','fixtures','chains',args[:chain_id].to_s)
      raise StandardError.new("chain #{args[:chain_id].to_s} does not exist") unless(File.exists?(directory_path))
      dump_file = File.open(File.join(directory_path,'dump'),'r')
           
      return Marshal.load(dump_file)          
      
    end
    
  end
  
  namespace :theories do
    
    desc "Create a new theory"
    task :create do 
      
      theory_id = "20"
   
      StandardLogger.instance.info("NOTE: Creating new theory fixture #{theory_id.to_s}")
      # Does a directory for this theory fixture already exist.
      directory_path = $LOC+File.join('test','fixtures','theories',theory_id.to_s)
      if(File.exists?(directory_path))
        StandardLogger.instance.warning("Theory ficture already exists #{theory_id.to_s} -cancelling")
        exit
      else
        
        # Create the directory
        FileUtils.mkdir_p(directory_path)
        
      end
      
      # This is just updated here - nothing fancy
      declaration = %q!
    dependent_one = TheoryDependent.new(StringToTheory.run("if(var2[var3].kind_of?(CTestCase))\nreturn true\nend"))
    dependent_two = TheoryDependent.new(
      StringToTheory.run("if((var2[var3][:params][var6] == var2[var4][:params][var6])==false)\nreturn true\nend")
    )
    action = TheoryAction.new(
      TheoryStatement.new(StringToTheory.run(
        'OpenStatement.new(Statement.new(If.new,Container.new(var1.params[var6],Equivalent.new,var2[var3][:params][var6])))'
      )),
      StringToTheory.run('var1.statement_id')
    )
    result_one = TheoryResult.new(StringToTheory.run(
      "if(var5.history2(var2[var3][:params]).any? { |x| x['statement_id'] == var1.last.statement_id })\nreturn true\nend"
    ))
    result_two = TheoryResult.new(StringToTheory.run(
      "if((var5.history2(var2[var4][:params]).any? { |x| x['statement_id'] == var1.last.statement_id })==false)\nreturn true\nend"
    ))    
    Theory.new(
      [dependent_one,dependent_two],
      action,
      [result_one,result_two]
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
    
    desc "Re create the current theories and update their Marshal dump"
    task :rebuild do
      
      file_list = FileList.new('test/fixtures/theories/*')
      file_list.each do |x|
        theory_id = x.match(/\d+$/)[0].to_i
        puts '* theory_id: '+theory_id.to_s    
        puts File.join('test','fixtures','theories',theory_id.to_s)
        directory_path = File.join('test','fixtures','theories',theory_id.to_s)
        puts directory_path
        declaration = File.open(File.join(directory_path,'declaration.txt'),'r').read
    
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
    
  end
  
end