fdlint -- 让前端code review更轻松
=================================

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

    ./fdlint <目标文件或目录>

或者

    ruby fdlint <目标文件或目录>

### Web

[fdlint-host](https://github.com/qhwa/fdlint-host)


## 源代码

    git clone git://github.com/qhwa/fdev-xray.git


## 目前进度

公开测试(Beta)中


## 附录

[扫描规则](https://github.com/qhwa/fdev-xray/wiki/fdlint-%E6%89%AB%E6%8F%8F%E8%A7%84%E5%88%99)
