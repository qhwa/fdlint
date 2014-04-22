# encoding: utf-8
# vi: filetype=ruby

js_rules

review( 'file' ) {
  desc "版权或维护信息在头部注释中声明"
  rule { |file, source|
    unless source =~ %r{^\s*
        /\*\*
        [^*]*
        \*+
        (?:[^/*][^*]*\*+)
        */}x
      warn '功能文件头必须有文档注释(以/**开始的多行注释)'
    end
  }
}

review( 'statement' ) { |stat|
  ary = %w(empty var continue break return throw expression)
  if ary.include?(stat.type) && !stat.end_with_semicolon?
    error '所有语句结束带上分号'
  end
}

review( 'stat_if' ) {

  rule { |stat|
    # if (condition1) state1;       <--- true_part
    # else if (condition2) state2;  <--- false_part of condition1
    #                                    true_part  of condition2
    # else state3;                  <--- false_part of condition2
    if stat.true_part.type != 'block' ||
        stat.false_part && stat.false_part.type != 'if' && stat.false_part.type != 'block'
      error '所有条件区域必须用花括号括起来'
    end
  }

  rule { |stat|
    count = 0;
    # 检查 "else if" 的数量
    while stat.false_part && stat.false_part.type == 'if'
      count += 1
      stat = stat.false_part
    end
    # 加上最后一个 "else"
    count += 1 if stat.false_part
    if count >= 3
      error '3个条件及以上的条件语句用switch代替if else'
    end
  }
}

review( 'expr_new' ) { |expr|
  expr = expr.left
  if expr.type == '('
    args = expr.right.elements
    expr = expr.left
  end

  if args.nil? || args.empty?
    if expr.text == 'Object'
      error '使用{}代替new Object()'
    elsif expr.text == 'Array'
      error '使用[]代替new Array()'
    end 
  end
}

review( 'expression' ) {

  rule { |expr|
    checks = %w(
      (.,window,eval)
      eval
    )
    if expr && expr.left && checks.include?(expr.left.text)
      error '不允许使用eval'
    end
  }

  rule { |expr|
    if expr.left && expr.left.text == 'alert'
      warn '必须去掉临时调试代码。如果一定要使用alert功能，请使用 window.alert'
    end
  }

  rule { |expr|
    if expr.left
      if expr.left.text =~ /(?<!this|self),_/
        error '禁止调用对象的私有方法'
      end
    end
  }

}

review( 'expr_equal' ) { |expr|
  if expr.type == '==' || expr.type == '!='
    warn '避免使用==和!=操作符'
  end
}

review( 'stat' ) { |stat|
  if stat.try_part.contains?('try') ||
      stat.catch_part && (stat.catch_part.contains? 'try') ||
      stat.finally_part && (stat.finally_part.contains? 'try')
    warn 'try catch一般不允许嵌套，若嵌套，需要充分的理由'
  end
}

# 检查是否有全局变量、全局函数
group( 'no global variables or functions' ) {

  scope_depth = 0
  scoped_vars = []

  before( 'program' ) { scope_depth = 0 }
  before( 'function_declaration' ) { scope_depth += 1 }

  after( 'function_parameters' ) { |params|
    scoped_vars << params.elements.map { |expr|
      if expr.type == "id"
        param_name = expr.left.text
      end
    }.compact
  }

  after( 'function_declaration' ) { |function|
    scoped_vars.pop
    scope_depth -= 1
  }

  review( 'expr_assignment' ) { |expr, source, file, parser|
    if expr.type == "="
      expr = expr.left
      if expr.type == "id" && !scoped_vars.flatten.include?( expr.left.text )
        error '禁止使用未定义的变量(或全局变量)'
      end
    end
  }

  review( 'stat_var_declaration' ) { |stat|
    error "禁止使用未定义的变量(或全局变量)" if scope_depth <= 0
  }

  review( 'function_name' ) { |name|
    error '不允许申明全局函数' if scope_depth <= 1
  }
}
