class CodeType

  class << self

    public
    def guess(text, filename=nil)
      if filename
        guess_by_name filename
      else
        guess_by_content text
      end
    end

    def guess_by_name( filename )
      case File.extname( filename )
      when /\.css$/i
        :css
      when /\.js$/i
        :js
      else
        :html #TODO: support more suffix
      end
    end

    def guess_by_content(text)
      return :html  if is_html? text
      return :css   if is_css? text
      :js #TODO: support more code syntaxes
    end

    def is_style_file?(filename)
      File.extname( filename ) =~ /(css|js|html?)$/i
    end

    def scope(filename)
      filename =~ /[\\\/]lib[\\\/]/ ? 'lib' : 'page'
    end

    private
    def is_html?(text)
      /^\s*</m =~ text
    end

    def is_css?(text)
      /^\s*@/m =~ text or /^\s*([-\*:\.#_\w]+\s*)+\{/ =~ text
    end

  end

end
