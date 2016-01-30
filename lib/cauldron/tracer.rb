module Cauldron

  class Tracer

    attr_reader :sexp, :results

    def initialize(sexp)
      @sexp = sexp
      @results = []
    end

    def process(example)
      object = Tracer.new(sexp)
      object.instance_eval(Sorcerer.source(sexp, indent: true))
      object.function(example.arguments.first)

      History.new(object.results)
    end

    def record(line, depth, total_line, entry)
      #h = Hash[*entry.flatten] 
      h = Hash[*entry.flatten(1)]
      h.merge!(:line => line)
      h.merge!(:depth => depth)
      h.merge!(:total_line => total_line)
      h = h.reject {|key,value| key.to_s.match /^placeholder/ }
      @results << h
      #@results << #entry # TODO Only want the trace to have on result so it should probably be in the initilaize call only
    end

    def self.substitue_tracking
      %q{
      record("line", "depth", "total_lines")
      }
    end    

    # def self.substitue_tracking
    #   %q{
    #   record("line", "depth", "total_lines", local_variables.reject { |foo|
    #     foo == :_
    #   }.collect { |bar|
    #     [bar, eval(bar.to_s)]
    #   })
    #   }
    # end

    def self.tracking(line, depth, total_line)
      [:method_add_arg,
       [:fcall, [:@ident, "record", [2, 0]]],
       [:arg_paren,
        [:args_add_block,
         [:args_add,
          [:args_add,
           [:args_add,
            [:args_add, [:args_new], [:@int, line, [2, 7]]],
            [:@int, depth, [2, 9]]],
           [:@int, total_line, [2, 11]]],
          [:method_add_block,
           [:call,
            [:method_add_block,
             [:call,
              [:vcall, [:@ident, "local_variables", [2, 13]]],
              :".",
              [:@ident, "reject", [2, 29]]],
             [:brace_block,
              [:block_var,
               [:params,
                [[:@ident, "foo", [2, 38]]],
                nil,
                nil,
                nil,
                nil,
                nil,
                nil],
               false],
              [:stmts_add,
               [:stmts_new],
               [:binary,
                [:var_ref, [:@ident, "foo", [2, 43]]],
                :==,
                [:symbol_literal, [:symbol, [:@ident, "_", [2, 51]]]]]]]],
            :".",
            [:@ident, "collect", [2, 54]]],
           [:brace_block,
            [:block_var,
             [:params, [[:@ident, "bar", [2, 65]]], nil, nil, nil, nil, nil, nil],
             false],
            [:stmts_add,
             [:stmts_new],
             [:array,
              [:args_add,
               [:args_add, [:args_new], [:var_ref, [:@ident, "bar", [2, 71]]]],
               [:method_add_arg,
                [:fcall, [:@ident, "eval", [2, 76]]],
                [:arg_paren,
                 [:args_add_block,
                  [:args_add,
                   [:args_new],
                   [:call,
                    [:var_ref, [:@ident, "bar", [2, 81]]],
                    :".",
                    [:@ident, "to_s", [2, 85]]]],
                  false]]]]]]]]],
         false]]]#]
    end

  end

end