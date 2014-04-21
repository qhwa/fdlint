module Fdlint

  module Printer

    class NoColorPrinter < BasePrinter

      def print( file, source, results )

        super

        if results.empty?
          puts "[OK] #{file}"
        else
          prf = @opt[:prefix]
          suf = @opt[:suffix]
          out = @opt[:out]

          puts "[EE] #{file}"

          results.each do |r|
            puts "#{prf}#{r}#{suf}"
          end
        end
      end

    end

  end
end
