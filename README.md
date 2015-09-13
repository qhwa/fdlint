## fdlint -- 让前端code review更轻松

fdlint 是根据阿里巴巴前端开发checklist开发的自动代码扫描工具。
可以扫描出前端程序中不符合开发规范的地方。

[![Build Status](https://secure.travis-ci.org/qhwa/fdlint.png)](http://travis-ci.org/qhwa/fdlint)
[![Code Climate](https://codeclimate.com/github/qhwa/fdlint.png)](https://codeclimate.com/github/qhwa/fdlint)

## 语言支持
* html
* css
* javascript

## 使用方式

### Web

[fdlint-host](https://github.com/qhwa/fdlint-host)


### 编辑器插件

* [Nodepad++ 插件](https://github.com/ThinkBest/fdlint-notepad-plusplus)
* [Vim 插件](https://github.com/qhwa/fdlint-vim)

### 命令行工具

#### ruby脚本

命令行工具是功能最全的方式。可以用来:

* 检查目录、文件
* 查看导入的规则

适合安装了Ruby1.9+ 环境的Windows/\*nix系统

安装

    gem install fdlint

运行方式(命令行):

    fdlint [参数] <目标文件或目录>
    fdlint [全局参数] 命令 [命令选项] [路径...]

或者使用管道：

    echo '* {}' | fdlint check

参数列表：

~~~
Usage:
    fdlint [全局参数] 命令 [命令参数] [路径...]

全局参数

    -d, --debug - 打印调试信息
    --help      - 显示帮助信息
    --version   - 显示版本号

子命令

    help          - 打印某个子命令的帮助，例如 fdlint help fdlint
    review, check - 检查代码。例如:
                    * fdlint check test.js
                    * fdlint check public/app/
                    * echo '<body></body>' | fdlint check
                    * fdlint check 
    rule          - 显示导入的规则
~~~

`fdlint check` 的参数:

~~~
    --format=arg        - 输出格式，可以是'vim', 'console' 或 'nocolor'. (默认: console)
    --html              - 仅检查 html 文件，或指定语法为 html
    --css               - 仅检查 css 文件，或指定语法为 css
    --js                - 仅检查 js 文件，或指定语法为 js
    -l, --list          - 等同于 '--format=list'
    --loglevel=arg      - 指定位于某个级别或更严重的错误才显示，可以是 'warn', 'error' 或 'fatal'
                          (默认: warn)
    -m, --[no-]checkmin - 检查已经被压缩的 js 或 css 文件。当扫描路径时，默认会忽略压缩文件
~~~


## 源代码

    git clone git://github.com/qhwa/fdlint.git

## 开源协议

[BSD协议](http://www.linfo.org/bsdlicense.html)

## 附录

[扫描规则](https://github.com/qhwa/fdlint/wiki/fdlint-%E6%89%AB%E6%8F%8F%E8%A7%84%E5%88%99)

