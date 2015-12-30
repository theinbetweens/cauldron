module Cauldron

  class Caret

    #attr_reader :line, :depth, :total_line
    attr_reader :total_lines, :line, :current_depth

    def initialize
      @total_lines, @current_depth, @line = 0, 0, 0
    end

    # TODO This approach will need re-worked to support nesting - in  and out
    def add_line(depth)
      @total_lines += 1
      if @current_depth != depth
        @current_depth = depth
        @line = 0
      else
        @line += 1
      end

    end

    def step_in
      @current_depth += 1
      @line = 0
    end

    def return_depth(depth)
      @current_depth = depth
    end

  end

end