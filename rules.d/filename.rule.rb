rules_for 'css', 'js'

review( 'file' ) {
  rule { |file|
    if file.name =~ /(?:[^a-z0-9%_-]|^)
      #以ad开头，与后面文字组合，构成常见的广告单词
      ad
      (?:
        [sv][^a-z\r=\?]+
        |[^a-z\r_-]*[\.\/]
        |bot|c_|client|council|gifs|graph|images|img
        |fshow|pic|vert|view|info|click|sponsor|banner
        |click|ver|name|x|log|
      )/x
      error '路径和文件名中不应该出现ad'
    end
  }

  desc '使用规范的文件名可以避免不同操作系统上的编码问题'
  uri  '#file-name'
  rule { |file|

    unless file.name =~ /\A[_\-a-zA-Z0-9\.]+\Z/
      error "文件名只能是英文字符"
    end

    if file.name =~ /[_]/
      warn "文件名中的连字符建议使用“-”而不是“_”"
    end

    win_disk = /^[a-zA-Z]:/
    if file.name.sub( win_disk, '') =~ /[A-Z]/
      error '文件夹和文件命名必须用小写字母'
    end
  }

}

helpers( 'file' ) {
  def page_level?
    !library_level?
  end

  def library_level?
    name =~ %r{/lib/}
  end
}


