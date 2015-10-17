$LOAD_PATH.unshift File.expand_path('../lib',__FILE__)

require 'cauldron'

a = %q{
def function(var1)
  var2 = var1.collect {|x| x + 2}
  var3 = var2.collect {|x| x.to_s }
end
}

b = %q{
def function2(var1)
  var2 = var1.collect do |x|
    x + 2
  end
  var3 = var2.collect do |x|
    x.to_s
  end
end
}



sexp = Ripper::SexpBuilder.new(b).parse


[
  [ArrayCollect.new, NumericOperator.new(2)]
  [ArrayCollect.new, ToSOperator.new]
]


a.build('var1')

  build(name, next_element)
    [:sdf, :dsfsd, next_element.build('x')]
  end
a.build('var2')

  build()
