Feature: Cauldron generates single parameter methods

	Cauldron can generate runtime methods that accepts one parameters
	
	NOTE: it creates the file in tmp/aruba/launch.rb - so that loading path needs to be changed
				- use @pause to see if it's working.

 	@announce, @slow_process
	Scenario: Method returns the passed in value
  	Given a file named "launch.rb" with:
      """
			$LOAD_PATH.unshift File.expand_path( File.join('..','..','lib') )
			require 'cauldron'
			cauldron = Cauldron::Terminal.new(STDOUT,false)
			cauldron.start
      """		
		When I run `ruby launch.rb` interactively
    And I add the case "sparky","sparky"
    And I type "RUN"
    Then it should pass with:
      """
      def method_0(var_0)
				return var_0
			end
      """
		