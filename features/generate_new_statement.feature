Feature: Cauldron generates single parameter methods

  Cauldron can generate runtime methods that accepts one parameters

  @announce @slow_process
  Scenario: Using statements that require a constant
    Given a file named "launch.rb" with:
      """
      $LOAD_PATH.unshift File.expand_path( File.join('lib') )
      require 'cauldron'
      cauldron = Cauldron::Pot.new
      puts cauldron.solve [{arguments: [8], response: 4}, {arguments: [12], response: 8}]
      """   
    When I run `ruby launch.rb` interactively
    Then the output should contain:
      """
      def function(var0)
        var0 - 4
      end
      """