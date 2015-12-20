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
      puts cauldron.solve [{arguments: [7], response: 8},{arguments: [10], response: 11}]
      """   
    When I run `ruby launch.rb` interactively
    Then the output should contain:
      """
      def function(var0)
        var0 + 1
      end
      """