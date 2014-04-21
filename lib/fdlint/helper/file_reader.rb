require 'string/utf8'

module Fdlint
  module Helper
    module FileReader
      extend self

      # auto detect file encoding and read it.
      # return with an array containing string
      # and encoding
      def readfile(path, opt={})
        bin = File.read(path).utf8!
        raise EncodingError.new unless bin.valid_encoding?
        bin
      end

    end
  end
end
