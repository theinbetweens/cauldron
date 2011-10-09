Feature: It should display a start up message

  @announce @slow_process
  Scenario: Interactive cauldron start up
    Given a file named "launch.rb" with:
      """
      $LOAD_PATH.unshift File.expand_path( File.join('lib') )
      require 'cauldron'
      cauldron = Cauldron::Terminal.new(STDOUT,false)
      cauldron.start
      """ 
    And I run `ruby launch.rb` interactively
    When I type "QUIT"
    Then the output should contain: 
      """
      Starting...
      """