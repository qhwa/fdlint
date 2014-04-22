module Fdlint; module Rule

  class Validation < Struct.new( :scope, :validate_block )

    attr_accessor :desc, :uri, :group

    def long_desc
      if desc
        uri ? desc + ", more info: #{uri}" : desc
      end
    end

    def to_s
      "<Validation #{scope} #{long_desc}>"
    end

    def inspect
      to_s
    end

    def to_visitor( opt={} )
      [
        scope,
        proc { |node, source, parser|
          exec( node, source, opt[:file], parser )
        }
      ]
    end

    def exec( node, source, file = nil, parser = nil )
      Runner.new.exec( node, source, file, parser, validate_block ) do |results|
        results.map do |msg, level, opt|
          pos = if node.respond_to?( :position ) && node.position
                  node.position
                else
                  opt[:pos]
                end

          if pos
            pos.column  += opt[:column_offset] if opt[:column_offset]
            pos.row     += opt[:row_offset] if opt[:row_offset]
            row, column  = pos.row, pos.column
          end

          LogEntry.new( msg, level, row, column ).tap do |entry|
            entry.validation = self
          end
        end
      end
    end

    class Runner

      def exec( node, source, file, parser, validate_block, &block )
        instance_exec( node, source, file, parser, &validate_block ) 
        yield results if block_given?
      end

      def results
        @results ||= []
      end

      def fatal( msg, opt={} )
        results << [msg, :fatal, opt]
      end
      
      def error( msg, opt={} )
        results << [msg, :error, opt]
      end

      def warn( msg, opt={} )
        results << [msg, :warn, opt]
      end


    end
  end

end; end
