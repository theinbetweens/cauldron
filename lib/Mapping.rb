# TODO  I'm not sure I like this approach? - maybe just a hash would be clearer
class Mapping
  
  attr_reader :hash
  
  def initialize(hash={})
    super()
    @hash = hash
  end
  
  def values
    return MappingValues.new(@hash.values)
  end
  
  def merge(mapping)
    return Mapping.new(@hash.merge(mapping.hash))
  end
  
  # TODO  Come back to this and include responds_to etc
  # http://stackoverflow.com/questions/291132/method-missing-gotchas-in-ruby
 def method_missing(sym, *args, &block)
    return @hash.send(sym, *args, &block) if @hash.respond_to?(sym)
    super(sym, *args, &block)
  end
  
end