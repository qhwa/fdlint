require_relative 'base_printer'

module XRay

  class VimPrinter < BasePrinter

    XRay.register_printer self

    def print(out=STDOUT)
      prf = @opt[:file].force_encoding('utf-8')
      @results.each do |r|
        out.puts "#{prf}:[#{r.level}]:#{r.row},#{r.column}:#{r.message}"
      end
      
    end

  end

end
