Feature: Cauldron generates single parameter methods

  Cauldron can generate runtime methods that accepts one parameters
  
  NOTE: it creates the file in tmp/aruba/launch.rb - so that loading path needs to be changed
        - use @pause to see if it's working.

  #TODO Change the method name

  @announce @slow_process
  Scenario: Method returns the passed in value
    Given a theory named "example_1.yml" with:
      """
      dependents:
        -
          "if RUNTIME_METHOD.kind_of?(RuntimeMethod)
            return true
          end"
        -
          "if ARG_1 == OUTPUT
            return true
          end"
      action:
        statement: "return x"
        values:
          x: ARG_1
        position: RUNTIME_METHOD.first.statement_id
      results:
        -
          RUNTIME_METHOD.all_pass(ARG_1)
      """ 
    And a file named "launch.rb" with:
      """
      $LOAD_PATH.unshift File.expand_path( File.join('lib') )
      require 'cauldron'
      cauldron = Cauldron::Pot.new
      cauldron.load_theory File.join('theories','example_1.yml')
      cauldron.generate [["sparky","sparky"],["kel","kel"]]
      """   
    When I run `ruby launch.rb` interactively
    Then the output should contain:
      """
      def extend_function_test_method(var1)
        return var1
      end
      """
      
    @announce @slow_process @wip      
    Scenario: Generate return fixed value solution
      Given a theory named "example_2.yml" with:
        """
        dependents:
          -
            if RUNTIME_METHOD.kind_of?(RuntimeMethod)
              return true
            end
          -
            if ARG_1 == OUTPUT
              return true
            end
        action:
          statement: "return x"
          values:
            x: OUTPUT
          position: RUNTIME_METHOD.first.statement_id
        results:
          -
            RUNTIME_METHOD.all_pass(ARG_1)
        """ 
      And a file named "launch.rb" with:
        """
        $LOAD_PATH.unshift File.expand_path( File.join('lib') )
        require 'cauldron'
        cauldron = Cauldron::Pot.new
        cauldron.load_theory File.join('theories','example_2.yml')
        puts cauldron.generate [["sparky","sparky"]]
        """   
      When I run `ruby launch.rb` interactively
      Then the output should contain:
        """
        def extend_function_test_method(var1)
          return "sparky"
        end
        """      

    @announce @slow_process
    Scenario: No theories loaded
      Given a file named "launch.rb" with:
        """
        $LOAD_PATH.unshift File.expand_path( File.join('lib') )
        require 'cauldron'
        cauldron = Cauldron::Pot.new
        puts cauldron.generate [["sparky","sparky"],["kel","kel"]]
        """   
      When I run `ruby launch.rb` interactively
      Then the output should contain:
        """
        There aren't any theories loaded so Cauldron is unable to generate a solution
        """
      