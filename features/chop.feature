Feature: Using String#chop

  Scenario: Using chop example
    Given I'm using the chop example
    When I generate a solution
    Then the solution should include:
      """
      def function(var0)
        var1 = var0.collect do |var2|
          var2.chop
        end
      end
      """    