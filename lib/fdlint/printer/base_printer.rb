module Fdlint

  module Printer

    class BasePrinter

      def initialize( opt={} )
        @opt= opt
      end

      attr_accessor :file, :source, :results

      def pre_validate( file )
      end

      def post_validate( file )
      end

      def print( file, source, results )
        @file, @source, @results = file, source, results || []
      end
    end

  end

end
