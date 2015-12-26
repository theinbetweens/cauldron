module Cauldron

  class Example

    attr_reader :arguments

    def initialize(hash)
      @arguments, @response = hash[:arguments], hash[:response]
    end

    def params
      @params ||= (0...@arguments.length).collect {|x| 'var'+x.to_s}
    end

  end

end