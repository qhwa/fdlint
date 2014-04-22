# encoding: utf-8
# vi: filetype=ruby

js_rules

JQ_IDS = %w(jQuery $ jQ jq)

review( 'expr_member' ) {

  desc '闭包写法："(function($, NS){....})(jQuery,Namespace);"'
  rule { |expr|
    if %w{. ( [}.include?(expr.type) && expr.left.text == "jQuery"
      unless expr.type == "." && expr.right.text == 'namespace'
        error '禁止直接使用jQuery变量，使用全局闭包写法，jQuery.namespace例外'
      end

    end
  }

  rule { |expr|
    if expr.type == '.' &&
        JQ_IDS.include?( expr.left.text ) &&
        %w[sub noConflict].include?( expr.right.text )

      error '禁止使用jQuery.sub()和jQuery.noConflict方法'
    end
  }

  rule { |expr|
    if expr.type == '('
      name = expr.left
      if name.type == '.' && name.right.text == 'data'
        param = expr.right[0]
        if param && param.text =~ /[-_]/
          error '使用".data()"读写自定义属性时需要转化成驼峰形式'
        end
      end
    end  
  }

  rule { |expr|
    if expr.type == '(' && JQ_IDS.include?(expr.left.text)
      param = expr.right[0] 
      if param && param.type == 'string' && param.text !~ /^['"][#\w<]/
        warn '使用选择器时，能确定tagName的，必须加上tagName'
      end
    end
  }
}
