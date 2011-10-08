
# => http://itshouldbeuseful.wordpress.com/2011/06/23/step-through-your-cucumber-features-interactively/
AfterStep('@pause') do
  print "Press Return to continue..."
  STDIN.getc
end

Before('@slow_process') do
  @aruba_io_wait_seconds = 3
  @aruba_timeout_seconds = 3
end

Before do
  @dirs = ["."]
end