require_relative 'base_printer'

module XRay

  class VimPrinter < BasePrinter

    XRay.register_printer self

    def print
      prf = (@opt[:file]||'').dup.utf8!
      @results.each do |r|
        puts "#{prf}:[#{r.level}]:#{r.row},#{r.column}:#{r.message}"
      end
      
    end

  end

end
