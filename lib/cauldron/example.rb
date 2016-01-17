module Cauldron

  class Example

    attr_reader :arguments, :response

    def initialize(hash)
      @arguments, @response = hash[:arguments], hash[:response]
    end

    def params
      (0...@arguments.length).collect {|x| 'var'+x.to_s}
      # @params ||= (0...@arguments.length).collect {|x| 'var'+x.to_s}
      # @params.freeze
      # @params
    end

  end

end