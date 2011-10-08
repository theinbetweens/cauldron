module Cauldron
  
  class Terminal
    
    include Cauldron::Conversion
    include Cauldron::Demos
    
    attr_reader :cases
    
    def initialize(output,auto=true)
      @output, @cases, @auto = output, [], auto
      
      # Create a logger for the user inputs
      #file = File.open('user-input.log', File::WRONLY | File::APPEND)
      file = File.open('user-input.log', 'w+')
      # To create new (and to remove old) logfile, add File::CREAT like;
      #   file = open('foo.log', File::WRONLY | File::APPEND | File::CREAT)
      @user_logger = Logger.new(file)      
      
    end
    
    def start
      @output.puts 'Starting....'
      @pot = Cauldron::Pot.new
      @pot.clear
      @output.puts '* Adding example case'      
      @pot.simmer(demo_one)
      @pot.simmer(demo_two)
      
      @output.puts "Thanks for trying Cauldron - it's at really early stage right now"
      @output.puts "in fact it can only generate a method that returns the parameter passed through"
      @output.puts ""
      @output.puts "To start enter your first test like this"    
      @output.puts "input,input,output"
      @output.puts "For example "
      @output.puts "'fish','animal'"
      @output.puts "'cat','animal'"
      @output.puts "'carrot','vegtable'"
      @output.puts "and when you're done just type RUN"

      # Wait for the user's inputs
      unless @auto
        loop do 
          submit gets
        end      
      end
      
    end
    
    def submit(input)
      
      @user_logger.info input
      
      if input =~ /^RUN$/
        @output.puts @pot.brew(@cases).reset_ids!.basic_write
      elsif input =~ /^QUIT$/
        # => TODO Include 'bye' output too
        #Process.exit!(true)
        at_exit {0}
        exit
      else
        @cases << convert_to_example(separate_values(input))
      end
    end   

  end
  
end