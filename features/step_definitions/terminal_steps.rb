
Given /^that the terminal has been created$/ do
  @terminal = Cauldron::Terminal.new(output)
  @terminal.start
end

Given /^I've started Cauldron$/ do
  When "I start cauldron"
end

When /^I start cauldron$/ do
  @terminal = Cauldron::Terminal.new(output)
  @terminal.start
end

# When /^I type "([^"]*)"$/ do |command|
  # @terminal.submit command
# end

# When /^I type "([^"]*)","([^"]*)"$/ do |param, output|
  # #type "'"+param+"','"+output+"'"
  # type 'test'
# end

When /^I add the case "([^"]*)","([^"]*)"$/ do |param, output|
  #pending # express the regexp above with the code you wish you had
  type "'"+param+"','"+output+"'"
end


# Then /^cauldron should say 'bye'$/ do
  # output.messages.should include('bye')
# end
# 
# Then /^the exit status should be (\d+)$/ do |exit_status|
  # @terminal.submit 'QUIT'
  # @last_exit_status.should == exit_status.to_i
# end

Then /^I should see "([^"]*)"$/ do |message|
   output.messages.should include(message)
end

Then /^then I should see "([^"]*)"$/ do |message|
  output.messages.should include(message)
end

When /^I add the case "([^"]*)"$/ do |test_case|
  @terminal.submit test_case  
end

Given /^that the terminal has been started$/ do
  @terminal = Cauldron::Terminal.new(output)
  @terminal.start  
end

Then /^the case "([^"]*)" should be saved$/ do |test_case|
  @terminal.cases.should include(convert_to_example(separate_values(test_case)))      
end