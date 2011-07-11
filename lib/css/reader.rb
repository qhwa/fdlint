require_relative '../encoding_error'

module XRay
  module CSS
    
    class Reader

      def self.read( file, opt = {} )
        options = {
          :encoding => 'utf-8'
        }.merge opt
        begin
          encoding = get_encoding_declaration(file)
          encoding ||= options[:encoding].to_s
          text = IO.read(file, :encoding => encoding)
          text.encode! 'utf-8'
        rescue Encoding::UndefinedConversionError, Encoding::InvalidByteSequenceError => e
          raise EncodingError.new
        end
      end

      def self.get_encoding_declaration( file )
        charset = nil
        begin
          File.open(file, 'r' ) do |f|
            line = f.readlines[0]
            charset = line[/(?<=@charset\s('|")).*(?=('|"))/]
          end
        rescue
        ensure
          charset
        end
      end
    end

  end

end
