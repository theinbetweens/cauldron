require 'find'
require 'test/unit'

class TestSuiteComplete < Test::Unit::TestCase
  
  def setup
  end
  
  def teardown
  end

  def test_all_test_cases_have_been_added
    test_cases = []
    Find.find('test') do |path|
      if FileTest.file?(path) && File.basename(path) =~ /^tc_.*\.rb$/ 
        test_cases << File.basename(path)
      end
    end
    missing = test_cases.inject([]) do |total,x|
       total << x unless open(File.join('test','ts_complete.rb')).read.include?(x.gsub(/\.rb$/,''))
       total
    end
    assert_equal(0,missing.length)
  end
  
end