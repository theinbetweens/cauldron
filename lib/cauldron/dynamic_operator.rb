module Cauldron

  class DynamicOperator

    attr_reader :indexes

    def initialize(information, sexp_methods)
      @information, @sexp_methods = information, sexp_methods
      @closed = false
    end

    def uses_constants?
      @information[:constants]
    end

    def indexes=(value)
      raise StandardError.new('') if @closed
      @indexes = value
    end

    def close
      @closed = true
    end

    def write_to_file(filename)
      File.open( File.join('tmp',filename), 'w+') do |file|
        file << "class DynamicOperator"+"\n"
        file << Sorcerer.source(@sexp_methods, indent: true)
        file << "\n"
        file << "end"
      end
    end

  end

end