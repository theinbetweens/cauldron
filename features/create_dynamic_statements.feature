Feature: Using dynamic method

  Scenario: Using the collect and + 7 example
    Given I'm using the collect and plus 7 example
    When I generate a solution
    Then the solution should include:
      """
      def function(var0)
        var1 = var0.collect do |var2|
          var2 + 7
        end
      end
      """ 