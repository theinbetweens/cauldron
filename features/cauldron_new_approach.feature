Feature: Cauldron generates single parameter methods

  Cauldron can generate runtime methods that accepts one parameters
  
  NOTE: it creates the file in tmp/aruba/launch.rb - so that loading path needs to be changed
        - use @pause to see if it's working.

  @announce @slow_process @new_approach
  Scenario: Method returns the passed in value
    Given a theory named "example_1.yml" with:
      """
        dependents:
          :1
            if RUNTIME_METHOD.kind_of?(RuntimeMethod)
              return true
            end
          :2
            if ARG_1 == OUTPUT
              return true
            end
        action:
          statement: "return x"
          values
            x: ARG_1
          position: RUNTIME_METHOD.first.statement_id
        results:
          :1
            RUNTIME_METHOD.all_pass(ARG_1)
      """ 
    And a file named "launch.rb" with:
      """
      $LOAD_PATH.unshift File.expand_path( File.join('lib') )
      require 'cauldron'
      #cauldron = Cauldron::Terminal.new(STDOUT)
      #cauldron.generate "sparky","sparky"
      cauldron = Cauldron::Pot.new
      cauldron.generate "sparky","sparky"
      """   
    When I run `ruby launch.rb` interactively
    Then the output should contain:
      """
      def method_0(var_0)
        return var_0
      end
      """