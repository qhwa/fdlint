fdlint -- 让前端code review更轻松
=================================

![fdlint-logo](http://q.pnq.cc/wp-content/uploads/2012/02/fdlint-logo-white.png)

fdlint (开发代号xray) 是根据阿里巴巴前端开发checklist开发的自动代码扫描工具。
可以扫描出前端程序中不符合开发规范的地方。

## 语言支持
* html
* css
* javascript

## 使用方式

### 编辑器插件

* [Nodepad++ 插件](https://github.com/ThinkBest/fdlint-notepad-plusplus)
* [Vim 插件](https://github.com/qhwa/fdlint-vim)

### 命令行工具

#### ruby脚本
适合安装了Ruby运行环境的Windows/\*nix系统

运行方式

    /path/to/fdlint [参数] <目标文件或目录>

或者使用管道：

    echo '* {}' | /path/to/fdlint

参数列表：

~~~
Usage: fdlint
        --css                        在扫描模式下仅检查CSS文件，在管道模式下指定内容为CSS
        --js                         在扫描模式下仅检查JS文件，在管道模式下指定内容为JS
        --html                       在扫描模式下仅检查HTML文件，在管道模式下指定内容为HTML
    -c, --charset set                指定文件默认的编码(本参数已废弃，目前自动判断字符集)
    -d, --debug                      输出调试信息
    -l, --list                       无彩色输出，等同于 '--format=nocolor'
    -m, --checkmin                   检查压缩后的js或css文件。如不指定改选项，会跳过*-min.css或*-min.js文件。
                                      (e.g. *-min.js; *-min.css)
        --format [type]              输出模式：console （默认）、nocolor 或 vim
        --level [log_level]          输出时消息的过滤等级：warn（默认）、error 或 fatal
~~~

### Web

[fdlint-host](https://github.com/qhwa/fdlint-host)


## 源代码

    git clone git://github.com/qhwa/fdlint.git


## 目前进度

公开测试(Beta)中


## 附录

[扫描规则](https://github.com/qhwa/fdlint/wiki/fdlint-%E6%89%AB%E6%8F%8F%E8%A7%84%E5%88%99)
