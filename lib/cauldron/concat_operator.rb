class ConcatOperator

  def initialize(constant)
    @constant = constant
  end

  def self.viable?(arguments, response)
    return false unless arguments.all? { |x| x.kind_of?(String) }
    return false unless response.kind_of?(String)
    # TODO - Only accpets one argument
    true
  end

  def self.find_constants(problems)
    problems.inject([]) do |total, x| 
      result = x[:response].gsub( Regexp.new('^'+x[:arguments].first),'')
      total << result unless result == x[:response]
      total
    end.uniq
  end

  def self.uses_constants?
    true
  end  

  # Operator for "x.concat("bar")"
  def successful?(problem)
    if (problem[:arguments].first + @constant) == problem[:response]
      return true
    end
    return false
  end

  def to_ruby
    '  var0.concat(\''+@constant.to_s+'\')'+"\n"
  end

end