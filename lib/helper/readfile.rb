# auto detect file encoding and read it.
# return with an array containing string
# and encoding
def readfile(path, opt={})
  if File.readable?(path)
    bin = File.read(path)
    %w(ascii-8bit utf-8 ucs-bom shift-jis gb18030 gbk gb2312 cp936).any? do |c|
      begin
        if bin.respond_to? :encode
          text = bin.encode('utf-8', c).force_encoding('utf-8')
        else
          require 'iconv'
          text = Iconv.new('UTF-8', c).iconv(bin)
        end
        return [text, c] if text =~ /./
      rescue => e
        next
      end
    end
    [bin, 'ASCII-8BIT']
  else
    raise ArgumentError.new("File is not readable!")
  end
end
