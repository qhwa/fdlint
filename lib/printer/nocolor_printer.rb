require_relative 'base_printer'

module XRay

  class NoColorPrinter < BasePrinter

    XRay.register_printer self

    def print
      if @results.empty?
        puts "[OK] #{@opt[:file]}"
      else
        prf = @opt[:prefix]
        suf = @opt[:suffix]
        out = @opt[:out]

        puts "[EE] #{@opt[:file]}"

        @results.each do |r|
          puts "#{prf}#{r}#{suf}"
        end
      end
    end

  end

end
