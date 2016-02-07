module Cauldron

  class Caret

    #attr_reader :line, :depth, :total_line
    attr_reader :total_lines, :current_depth

    def initialize
      @total_lines, @current_depth = 0, 0 #,@line = 0, 0, 0
      @lines = { 0 => 0}
    end

    # TODO This approach will need re-worked to support nesting - in  and out
    def add_line(depth)
      unless @lines.has_key?(depth)
        @lines[depth] = 0
      end

      @total_lines += 1
      if @current_depth != depth
        @current_depth = depth
      else
        @lines[depth] += 1
      end

    end

    def point
      
    end

    def line
      @lines[@current_depth]
    end

    def step_in
      @current_depth += 1
      unless @lines.has_key?(@current_depth)
        @lines[@current_depth] = 0
      end      
      #@line = 0
    end

    def return_depth(depth)
      @current_depth = depth
    end

  end

end