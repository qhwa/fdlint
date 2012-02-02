# encoding: utf-8

class String

  @@encs = %w(ascii utf-8 gb18030 gbk gb2312 cp936 big5)

  class << self
    def encs; @@encs; end
    def encs=(arr); @@encs = arr; end
  end

  if self.respond_to? :encode!
    def try_convert to, from
      self.encode!( to, from ).force_encoding( to )
      self.valid_encoding?
    end
  else
    require 'iconv'
    def try_convert to, from
      text = Iconv.new(to, from).iconv(self)
      self.replace(text) if self =~ /./
    end
  end

  attr_reader :former_enc

  def enc!(encoding)
    @@encs.each do |c|
      begin
        puts "#{c} => #{encoding}"
        if self.send :try_convert, encoding, c
          @former_enc = c
          break
        end
      rescue => e
        puts e
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
  src = "test 中文" 
  src.gb2312!
  puts src

  src.utf8!
  puts src
end
