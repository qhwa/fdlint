require_relative '../encoding_error'
require_relative '../helper/file_reader'

module XRay
  module CSS
    
    class Reader
      
      include XRay::Helper

      def self.read( file, opt = {} )
        source, enc = FileReader::readfile(file)
        declare = get_encoding_declaration(file)
        if declare and enc != declare
          raise EncodingError.new
        end
        source
      end

      def self.get_encoding_declaration( file )
        begin
          File.open(file, &:readline)[/@charset\s+(['"])(.*?)\1/, 2]
        rescue
        end
      end
    end

  end

end
