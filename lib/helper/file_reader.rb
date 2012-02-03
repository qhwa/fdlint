require_relative 'strenc'

module XRay
  module Helper
    module FileReader
      extend self

      # auto detect file encoding and read it.
      # return with an array containing string
      # and encoding
      def readfile(path, opt={})
        if File.readable?(path)
          bin = File.read(path).utf8!
          [bin, bin.former_enc ||'ascii-8bit' ]
        else
          raise ArgumentError.new("File is not readable!")
        end
      end

    end
  end
end
