require_relative '../encoding_error'

module XRay
  module CSS
    
    class Reader

      def self.read( file, opt = {} )
        options = { :encoding => 'utf-8' }.merge opt
        begin
          encoding = get_encoding_declaration(file) || options[:encoding].to_s
          File.read(file, :encoding => encoding).encode! 'utf-8'
        rescue Encoding::UndefinedConversionError, Encoding::InvalidByteSequenceError
          raise EncodingError.new
        end
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
