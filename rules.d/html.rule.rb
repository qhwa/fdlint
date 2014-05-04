# encoding: utf-8
html_rules

review( 'doc' ) { |doc|
  unless doc.have_dtd?
    error "必须存在文档类型声明"
  end
}

review( 'dtd' ) { |dtd|
  unless dtd.type =~ /^html$/i
    warn '推荐使用HTML 5 DTD'
  end

  unless dtd =~ /^<!DOCTYPE/
    warn '必须使用大写的"DOCTYPE"'
  end
}

review( 'property' ) { |prop|

  # Bad case: <div style="padding:0">...</div>
  if prop =~ /^style$/im
    error "不能定义内嵌样式style"
  end

  if prop =~ /[A-Z]/
    error "属性名必须小写"
  end

  if prop =~ /_/
    error "属性名连字符用中横线"
  end

  if prop =~ 'id' and prop.value =~ /[A-Z]/
    error "id名称全部小写，单词分隔使用中横线"
  end

  if prop =~ 'class' and prop.value =~ /[A-Z]/
    error "class名称全部小写"
  end
  if prop =~ 'class' and prop.value =~ /[_]/
    error "class名称单词分隔使用中横线"
  end

  if prop.value and prop.sep != '"'
    error "属性值必须使用双引号"
  end

  if prop.value.nil?
    error "不能仅有属性名"
  end

}

review( 'tag' ) { |tag|

  if tag =~ /[A-Z]/ || tag.ending =~ /[A-Z]/
    error "标签名必须小写"
  end

  if tag =~ 'img'
    unless tag.has_prop?( 'alt' )
      error "img标签必须加上alt属性"
    end
  end

  if tag =~ 'a' and tag['href'] =~ /^[^#]/
    unless tag['title']
      error '非功能能点的a标签必须加上title属性'
    end
  end
}

review( 'tag' ) {

  has_target = false

  before( 'doc' ) {
    has_target = false
  }

  # <base target='_self'>
  after( 'tag' ) { |tag|
    if tag =~ 'base' and tag['target'] == '_self'
      has_target = true
    end
  }

  rule { |tag|
    unless has_target
      if tag =~ 'a' and tag['href'] =~ /^#/ and tag['target'] != '_self'
        warn '功能a必须加target="_self"，除非preventDefault过'
      end
    end
  }

}

group( 'uniq links' ) {

  scripts_used = nil
  styles_used  = nil

  before( 'doc' ) {
    scripts_used = []
    styles_used  = []
  }

  review( 'tag' ) { |tag|
    if tag =~ 'script'
      src = tag['src'].to_s
      if src.present?
        if scripts_used.include?( src )
          error "避免重复引用同一文件"
        else
          scripts_used << src
        end
      end
    elsif tag.stylesheet_link?
      src = tag['href'].to_s
      if src.present?
        if styles_used.include?( src )
          error "避免重复引用同一文件"
        else
          styles_used << src
        end
      end
    end
  }
}


review( 'tag' ) { |tag|

  if tag =~ 'style' and tag.inner_text =~ /@import\s/m
    error "不通过@import在页面上引入CSS"
  end

  if tag =~ 'head'
    
    children  = tag.children
    has_meta  = children.any? { |e| e =~ 'meta' and e['charset'] }
    has_title = children.any? { |e| e =~ 'title' }

    unless has_meta and has_title
      error "head必须包含字符集meta和title"
    end
  end

  if !(tag =~ 'a') and tag.inline? and tag.children.any? { |e| !e.inline? }
    error "行内标签不得包含块级标签，a标签例外"
  end

  if (tag =~ 'input') and tag['type'].to_s =~ /text|radio|checkbox/ or
      tag =~ /^(select|textarea)$/

    if tag['name'].blank?
      error "text、radio、checkbox、textarea、select必须加name属性"
    end
  end

  if tag =~ /input/ and tag['type'].to_s =~ /button|submit|reset/
    error "所有按钮必须用button（button/submit/reset）"
  end

  if tag.stylesheet_link?
    if !tag.in_scope?('head')
      warn "外链CSS置于head里(例外：应用里的footer样式)"
    end
  end

  if !tag.closed?
    error "标签必须正确闭合"
  end
}

review( 'text_tag' ) do |text_tag, source, file|
  if text_tag.text =~ /[<>]/ && !(text_tag.in_scope?('script') || text_tag.in_scope?('style'))
    error "特殊HTML符号(>和<)必须转义"
  end
end
