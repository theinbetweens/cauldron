Feature: Cauldron generates single parameter methods

  Cauldron can generate runtime methods that accepts one parameters

  @announce @slow_process
  Scenario: Chop the last character off a string
    Given a file named "launch.rb" with:
      """
      $LOAD_PATH.unshift File.expand_path( File.join('lib') )
      require 'cauldron'
      cauldron = Cauldron::Pot.new
      puts cauldron.solve [{arguments: ['Sparky'], response: 'Spark'}, {arguments: ['Kel'], response: 'Ke'}]
      """   
    When I run `ruby launch.rb` interactively
    Then the output should contain:
      """
      def function(var0)
        var0.chop
      end
      """

  @announce @slow_process
  Scenario: Chop the last character off a string
    Given a file named "launch.rb" with:
      """
      $LOAD_PATH.unshift File.expand_path( File.join('lib') )
      require 'cauldron'
      cauldron = Cauldron::Pot.new
      puts cauldron.solve [
        {arguments: [['Sparky', 'Kels']], response: ['Spark', 'Kel']}, 
        {arguments: [['Pip','Rowe']], response: ['Pi','Row']}
      ]
      """   
    When I run `ruby launch.rb` interactively
    Then the output should contain:
      """
      def function(var0)
        var2 = var0.collect do |var1|
          var1.chop
        end
      end
      """