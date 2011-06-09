Feature: Cauldron starts on the command line
	I want cauldron to start 
	So that I can describe the method I want it generate
	Scenario: start cauldron
		When I start cauldron
		Then I should see "Thanks for trying Cauldron - it's at really early stage right now"
		And then I should see "To start enter your first test like this"
		And then I should see "input,input,output"
		And then I should see "For example "
		And then I should see "'fish','animal'"
		And then I should see "'cat','animal'"
		And then I should see "'carrot','vegtable'"
		And then I should see "and when you're done just type RUN"