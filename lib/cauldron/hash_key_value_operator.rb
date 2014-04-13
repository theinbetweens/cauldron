#http://www.ruby-doc.org/core-2.1.1/Hash.html
#hsh[key] → value
class HashKeyValueOperator

  def initialize(constant)
    @constant = constant
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

end