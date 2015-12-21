class ToSOperator

  def initialize(indexes)
    @indexes = indexes
  end

  def build(operators, scope)
    [
      :call,
      [:vcall, 
        [:@ident, scope[@indexes[0]]]
      ],
      :".",
      [:@ident, "to_s"]
    ]  
  end

end