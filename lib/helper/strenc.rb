# encoding: utf-8

class String

  @@encs = %w(ascii utf-8 gb18030 gbk gb2312 cp936 big5)

  class << self
    def encs; @@encs; end
    def encs=(arr); @@encs = arr; end
  end

  if public_instance_methods.include? :encode!
    def try_convert to, from
      encode!( to, from ).force_encoding( to )
      valid_encoding?
    end
  else
    require 'iconv'
    def try_convert to, from
      text = Iconv.new(to, from).iconv(self)
      replace(text) if self =~ /./
    end
  end

  attr_reader :former_enc

  def enc!(encoding)

    if respond_to? :force_encoding
      force_encoding encoding
      if valid_encoding?
        @former_enc = encoding
        return self 
      end
    end
    
    @@encs.each do |c|
      begin
        if send :try_convert, encoding, c
          @former_enc = c
          break
        end
      rescue => e
      end
    end
    self
  end

  @@encs.each do |tar|
    mtd = tar.gsub(/-/, '') << "!"
    define_method mtd do
      enc! tar
    end
    public mtd
  end

  private :try_convert

end


if __FILE__ == $0
  puts File.read('test/fixtures/html/1-1.html').utf8!
end
