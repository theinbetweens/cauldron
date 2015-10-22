#http://www.ruby-doc.org/core-2.1.1/Hash.html
#hsh[key] → value
class HashKeyValueOperator

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

  def to_ruby(variables)
    if @constant.kind_of?(Symbol)
      return %Q{  #{variables[@indexes[0]]}[:#{@constant}]}+"\n"
    end
    %Q{  #{variables[@indexes[0]]}['#{@constant}']}+"\n"
  end

  def build(operators, variables)
    
  end

end