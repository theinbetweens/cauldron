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

  Scenario: Using the collect and + 5 example
    Given I'm using the collect and + 5 example
    When I generate a solution
    Then the solution should include:
      """
      def function(var0)
        var1 = var0.collect do |var2|
          var2 + 5
        end
      end
      """    