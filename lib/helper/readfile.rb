# auto detect file encoding and read it.
# return with an array containing string
# and encoding
def readfile(path, opt={})
  %w(utf-8 gb18030 gbk gb2312 cp936).any? do |coding|
    begin
      text = File.read(path, :encoding => coding).encode!("utf-8")
      return [text,coding] if text =~ /.*/
    rescue ArgumentError, Encoding::UndefinedConversionError, Encoding::InvalidByteSequenceError => e
      next
    end
  end
end


