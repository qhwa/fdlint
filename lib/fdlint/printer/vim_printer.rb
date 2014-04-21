module Fdlint

  module Printer

    class VimPrinter < BasePrinter

      def print( file, source, results )
        prf = ( file || '-' ).dup.utf8!
        results.each do |r|
          if r.row
            puts "%s:[%s]:%d:%d:%s" % [prf, r.level, r.row, r.column, r.message]
          else
            puts "%s:[%s]:%d:%d:%s" % [prf, r.level, 0, 0, r.message]
          end
        end
      end

    end

  end
end
