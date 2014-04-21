require 'colored'

module Fdlint 

  module Printer

    class ConsolePrinter < BasePrinter

      def print( file, source, results )

        super

        if source
          print_with_source
        else
          if @results && @results.empty?
            puts "[OK] ".green << file.to_s
          else
            puts "[EE] ".red << file.to_s

            @results.each do |r|
              print_log_entry r
            end
          end
        end
      end

      def print_with_source
        if @results.empty?
          puts "[OK] ".green << file.to_s
        else
          puts "[EE] ".red << file.to_s

          @results.each do |r|
            print_log_entry r
          end
        end
        

      end

      def print_log_entry( entry )
        if entry.row && entry.row > 0
          col    = entry.column - 1
          row    = entry.row - 1
          left   = col - 50
          right  = col + 50
          left   = 0 if left < 0
          indent = ' ' * ( col - left )

          puts "     #{log_text entry}\n"
          puts "       #{source.lines[row][left..right].gsub(/\t/, ' ')}"
          puts "       #{indent}^"
        else
          puts "     #{log_text entry}\n"
        end
      end


      def log_text( entry )
        level = entry.level.to_s.upcase.ljust(5)
        t = if entry.warn?
              level.yellow
            elsif entry.fatal?
              level.white_on_red
            elsif entry.error?
              level.red
            else
              level
            end
        if entry.row
          "[%s] %s %s" % [t, entry.pos, entry.message]
        else
          "[%s] %s" % [t, entry.message]
        end
      end
    end

  end
end