module Fdlint

  module Printer

    class BasePrinter

      def initialize( opt={} )
        @opt= opt
      end

      attr_accessor :file, :source, :results

      def print( file, source, results )
        @file, @source, @results = file, source, results || []
      end
    end

  end

end
