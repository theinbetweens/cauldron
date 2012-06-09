module Cauldron
  
  class Theory
    
    attr_reader :dependents, :action, :results
    
    def initialize(dependents,action,results)
      @dependents, @action, @results = dependents, action, results
    end
    
    def ==(subject)
      return false unless subject.dependents == @dependents
      return false unless subject.action == @action
      subject.results == @results
    end

    def insert_statement

      # Change the names of all ARG values
      # {:statement => 
      #     'return x',
      #     :values => {:x => 'ARG_1'},
      #     :position => 'RUNTIME_METHOD.first.statement_id'
      # },
      values = @action['values'].clone      
      values = @action['values'].inject({}) do |hash, (key, value)| 
        if value == 'ARG_1'
          hash[key] = 'var1'
        end
        hash
      end
      
      # http://stackoverflow.com/questions/10357303/ruby-string-substitution
      # Might be better with
      # num1 = 4  
      # num2 = 2  
      # print "Lucky numbers: %d %d" % [num1, num2]

      # or

      # num1 = 4  
      # num2 = 2  
      # puts "Lucky numbers: #{num1} #{num2}";      

      # TODO Maybe save the statemetns in the format 'return %x'


      # evalue all the variables - 
      #TODO Stick in some sort of sandbox here
      parser    = RubyParser.new
      ruby2ruby = Ruby2Ruby.new  
      sexp      = parser.process(@action['statement'])      

      # Construct the declarations
      puts '-================== START'
      puts values.inspect
      res = nil
      values.each do |key,value|
        match = s(:call, nil, key.to_sym, s(:arglist))
        replace = s(:call, nil, value.to_sym, s(:arglist))
        puts '=-----------inside'
        puts value
        res = sexp.gsub(match,replace)
        puts sexp
      end
      puts '--------------------'
      res = ruby2ruby.process(res)
      puts res
      res
      #puts res.class

    end
   
  end
  
end