
# When /^I add these "([^"]*)"$/ do |test_cases_statement|
  # test_cases = test_cases_statement.split('*')
  # test_cases.each do |x|
    # @terminal.submit x 
  # end
# end

Given /^a theory named "([^"]*)" with:$/ do |file_name, string|
  steps %Q{
    Given a file named "#{file_name}" with:
      """
      #{string}
      """
  }
  FileUtils.mkdir_p(File.join(home,'cauldron','tmp'))
  FileUtils.cp File.join('.',file_name), File.join(home,'cauldron','tmp',file_name)
end

When /^I add a case with a param "([^"]*)" and an expected output of "([^"]*)"$/ do |param, output|
  #@terminal.submit("'"+param+,"'+output+'"')  
  @terminal.submit("'#{param}','#{output}'")
end

Then /^I should receive a runtime method like this "([^"]*)"$/ do |runtime_method_statement|
  runtime_method_statement = runtime_method_statement.gsub('\\n',"\n").gsub('\\t',"\t")
  @terminal.submit('RUN')
  output.messages.should include(runtime_method_statement)
end

Given(/^I'm using the chop example$/) do
  #pending # Write code here that turns the phrase above into concrete actions
  @pot = Cauldron::Pot.new
  @examples = [
    {arguments: [['Sparky', 'Kels']], response: ['Spark', 'Kel']}, 
    {arguments: [['Pip','Rowe']], response: ['Pi','Row']}
  ]
end

Given(/^I'm using the simple chop example$/) do
  @pot = Cauldron::Pot.new
  @examples = [
    {arguments: ['Andy'], response: 'And'}, 
    {arguments: ['Kels'], response: 'Kel'}
  ]
end

Given(/^I'm using the reverse example$/) do
  @pot = Cauldron::Pot.new
  @examples = [
    {arguments: [['Sparky', 'Kels']], response: ['Kels', 'Sparky']}
  ]  
end

Given(/^I'm using the collect and \+ (\d+) example$/) do |arg1|
  @pot = Cauldron::Pot.new
  @examples = [
    {arguments: [[5,7]], response: [10, 12]},
    {arguments: [[9,15]], response: [14, 20]}
  ]    
end

When(/^I generate a solution$/) do
  @solution = @pot.solve @examples
end

Then(/^the solution should include:$/) do |string|
  @solution.should include(string)
end

