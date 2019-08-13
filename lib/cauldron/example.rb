# frozen_string_literal: true

module Cauldron
  class Example
    attr_reader :arguments, :response

    def initialize(hash)
      @arguments = hash[:arguments]
      @response = hash[:response]
      @arguments.freeze
    end

    def params
      (0...@arguments.length).collect { |x| 'var' + x.to_s }
    end
  end
end
