class IfRelationship < Relationship

  def initialize(problems)
    @problems = problems
  end

  def to_ruby

    # Add the arguments
    args = @problems.first[:arguments]
    variables = (0...args.length).collect {|x| 'var'+x.to_s}
    result = ''
    @problems.each_with_index do |x,i|
      result += '  if '+variables[0].to_s+' == '+quote(x[:arguments][0])+"\n"
      result += '    return '+quote(x[:response])+"\n"
      result += '  end'+"\n"
    end    
    result
  end

  def self.match?(problems)
    true
  end

protected

  # TODO Not Dry - method used in Pot
  def quote(value)
    if value.kind_of?(String)
      return "'#{value}'"
    end
    value.to_s
  end

end