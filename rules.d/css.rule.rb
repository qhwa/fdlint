# CSS review rules
# Author: @qhwa

css_rules

review( 'selector' ) {

  desc "页面级别样式请用class选择符代替id选择符，以免在重用时影响其他页面"
  rule { |selector, source, file|
    if file && file.page_level?  && selector =~ /#/
      error '页面级别样式不使用id'
    end
  }

  desc "页面级别的样式如果使用 body、p 等全局标签样式，会增加复用难度"
  rule { |selector, source, file|
    if file && file.page_level? && selector =~ /^\w+$/
      error '页面级别样式不能全局定义标签样式'
    end
  }

  desc "过多的 '>' 层级会影响性能"
  rule { |selector|
    if selector.text.split(/[>\s]/).length > 4
      error 'CSS级联深度不能超过4层'
    end
  }

  rule { |selector|
    if selector =~ /^\*/
      error '禁止使用星号选择符'
    end
  }

  rule { |selector|
    if selector =~ /\S\*/
      error '合理使用hack'
    end
  }
}

review( 'declaration' ) {
  rule { |declaration|
    if declaration.property =~ /^font(-family)?$/ && declaration.value =~ /\p{Han}+/u
      error '字体名称中的中文必须用ascii字符表示'
    end
  }
}

review( 'ruleset' ) {

  uri 'http://wd.alibaba-inc.com/doc/page/regulations/css'
  rule { |ruleset|
    list = [
      %w(position display visible z-index overflow float clear),
      %w(width height top right bottom left margin padding border),
      %w(background opacity),
      %w(font color text line-height vertical-align)
    ] 

    now = 0
    ruleset.declarations.each do |dec|
      prop_text = dec.property.text
      index = list.find_index do |bag| 
        bag.any? { |field| prop_text.include? field }
      end 

      if index
        if index < now
          warn '建议使用Mozilla推荐CSS书写顺序'
          break
        end
        now = index
      end
    end
    nil
  }
}

review( 'property' ) {
  rule { |property|
    if property =~ /[^-a-z]/
      error '合理使用hack'
    end
  }
}

review( 'value' ) {
  rule { |value|

    if value =~ /^expression\(/
      error '禁止使用CSS表达式'
    end

    if value =~ /\\\d$/
      error '合理使用hack'
    end
  }
}

