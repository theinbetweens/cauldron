#http://www.ruby-doc.org/core-2.1.1/Hash.html
#hsh[key] → value
class HashKeyValueOperator

  # var0[:foo]

  def initialize(indexes, constant)
    @constant, @indexes = constant, indexes
  end

  def self.viable?(arguments, response)
    return false unless arguments.all? { |x| x.kind_of?(Hash) }
    true
  end

  def self.uses_constants?
    true
  end

  def self.find_constants(problems)
    problems.collect {|x| x[:arguments].first.keys }.flatten
  end

  def successful?(problem)
    if problem[:arguments].first[@constant] == problem[:response]
      return true
    end
    return false    
  end

  def to_ruby(operators, variables)
    Sorcerer.source build(operators, variables)
    # if @constant.kind_of?(Symbol)
    #   return %Q{  #{variables[@indexes[0]]}[:#{@constant}]}+"\n"
    # end
    # %Q{  #{variables[@indexes[0]]}['#{@constant}']}+"\n"
  end

  def build(operators, variables)
    to_sexp(variables)
  end

  def to_sexp(variables)
    [:aref,
      [:vcall, 
        [:@ident, variables[0]]
      ], 
      [:args_add_block, 
        [:args_add, [:args_new], 
        sexp_index
          # [constant_literal, 
          #   [:symbol, [:@ident, @constant]]
          #   [:string_add, [:@ident, @constant]]
          # ]
        ]
      ]
    ]
    #[:program, [:stmts_add, [:stmts_new], [:aref, [:vcall, [:@ident, "var0"]], [:args_add_block, [:args_add, [:args_new], [:symbol_literal, [:symbol, [:@ident, "foo", [1, 6]]]]], false]]]]    

    # [:program, [:stmts_add, [:stmts_new], [:aref, [:vcall, [:@ident, "var0", [1, 0]]], [:args_add_block, [:args_add, [:args_new], [:string_literal, [:string_add, [:string_content], [:@tstring_content, "foo", [1, 6]]]]], false]]]]
  end 

  def sexp_index
    if @constant.kind_of?(Symbol)
      a = [
            :symbol_literal, 
            [:symbol, [:@ident, @constant]],
            [:string_add, [:@ident, @constant]]
          ]
      return a      
    elsif @constant.kind_of?(String)
      return [
                :string_literal, 
                [
                  :string_add, 
                  [:string_content], 
                  [:@tstring_content, @constant ]
                ]
            ] 
    else
      raise StandardError.new('Unknown index')
    end
  end 

end