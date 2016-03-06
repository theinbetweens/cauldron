Feature: Using dynamic method

  Scenario: Using the collect and + 5 example
    Given I'm using the collect and + 5 example
    When I generate a solution
    Then the solution should include:
      """
      def function(var0)
        var0.collect do |var1|
          var1 + 5
        end
      end
      """ 