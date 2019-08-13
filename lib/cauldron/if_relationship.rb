# frozen_string_literal: true

class IfRelationship # < Relationship
  # TODO: Need to change to IfSolution probably

  def initialize(problems)
    @problems = problems
  end

  def to_ruby(variables)
    # Add the arguments
    result = ''
    @problems.each_with_index do |x, _i|
      result += '  if ' + variables[0].to_s + ' == ' + quote(x.arguments[0]) + "\n"
      result += '    return ' + quote(x.response) + "\n"
      result += '  end' + "\n"
    end
    result
  end

  def self.match?(_problems)
    true
  end

  protected

  # TODO: Not Dry - method used in Pot
  def quote(value)
    return "'#{value}'" if value.is_a?(String)

    value.to_s
  end
end
