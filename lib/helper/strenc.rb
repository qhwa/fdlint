# encoding: utf-8

class String

  @@encs = %w(ascii-8bit utf-8 gb18030 gbk gb2312 cp936 big5)

  class << self

    def encs
      @@encs
    end

    def encs=(arr)
      @@encs = arr
    end

    private
    def init_strenc_with_native
      define_method :enc! do |encoding|
        @@encs.each do |c|
          begin
            self.encode!( encoding, c ).force_encoding( encoding )
            if self.valid_encoding?
              @former_enc = c
              break
            end
          rescue
          end
        end
        self
      end
    end

    def init_strenc_with_iconv
      require 'iconv'
      instance_eval do
        define_method :enc! do |encoding|
          @@encs.each do |c|
            begin
              text = Iconv.new(encoding, c).iconv(self)
              if self =~ /./
                @former_enc = c
                break
              end
            rescue
            end
          end
          self
        end
      end
    end

  end

  if self.public_instance_methods.include? :encode!
    self.send :init_strenc_with_native
  else
    self.send :init_strenc_with_iconv
  end

  attr_reader :former_enc

  @@encs[1..-1].each do |tar|
    mtd = tar.gsub(/-/, '') << "!"
    define_method mtd do
      enc! tar
    end
    public mtd
  end


end

