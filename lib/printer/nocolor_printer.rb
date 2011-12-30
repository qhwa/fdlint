require_relative 'base_printer'

module XRay

  class NoColorPrinter < BasePrinter

    XRay.register_printer self

    def print
      out = @opt[:out]
      if @results.empty?
        out.puts "[OK] #{@opt[:file]}"
      else
        prf = @opt[:prefix]
        suf = @opt[:suffix]
        out = @opt[:out]

        out.puts "[EE] #{@opt[:file]}"

        @results.each do |r|
          out.puts "#{prf}#{r}#{suf}"
        end
      end
    end

  end

end
