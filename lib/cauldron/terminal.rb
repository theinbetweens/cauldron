# frozen_string_literal: true

module Cauldron
  class Terminal
    def initialize(output = STDOUT)
      @output = output
    end
  end
end
