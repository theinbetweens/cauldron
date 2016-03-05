Feature: Using Array#reverse

  Scenario: Using chop example
    Given I'm using the reverse example
    When I generate a solution
    Then the solution should include:
      """
      def function(var0)
        var0.reverse
      end
      """    