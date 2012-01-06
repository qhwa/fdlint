require_relative 'base_printer'

if ENV['OS'] =~ /windows/i
  require 'win32console' 
end


module XRay

  class ConsolePrinter < BasePrinter

    XRay.register_printer self

    def print
      if @opt[:source]
        print_with_source
      else
        if @results.empty?
          puts "[OK]".white.green_bg << " #{@opt[:file]}"
        else
          prf = @opt[:prefix]
          suf = @opt[:suffix]

          puts ""
          puts "[EE] #{@opt[:file]}".white.magenta_bg

          @results.each do |r|
            puts "#{prf}#{r.to_color_s}#{suf}"
          end
        end
      end
    end


    def print_with_source
      if @results.empty?
        puts "[OK]".white.green_bg << " #{@opt[:file]}"
      else
        source = @opt[:source]
        lines = source.split(/\r\n|\n|\r/)
        prf = @opt[:prefix]
        suf = @opt[:suffix]

        puts "[EE] #{@opt[:file]}".white.magenta_bg

        @results.each do |r|
          if r.row && r.row > 0
            col = r.column - 1
            row = r.row - 1
            left = col - 50
            right = col + 50
            left = 0 if left < 0

            puts "#{prf}#{lines[row][left..right].gsub(/\t/, ' ')}"
            puts "#{prf}#{' ' * (col - left)}^ #{r.to_color_s}"
            puts "\n"
          else
            puts "#{r.to_color_s}#{suf}\n"
          end
        end
      end
      
    end
  end

end
