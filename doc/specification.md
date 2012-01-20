# fdlint 扫描规则

## css

* [error] 静态文件编码应为国标码（gbk/gb2312）
* [error] 页面级别样式不使用id
* [error] 页面级别样式不能全局定义标签样式		
* [error] CSS级联深度不能超过4层		
* [error] 合理使用hack		
* [error] 字体名称中的中文必须用ascii字符表示		
* [error] 禁止使用星号（\*）选择符		
* [error] 禁止重写reset中定义的a标签的hover色（现为#ff7300）		
* [error] 禁止修改或重载type中的样式		
* [error] 禁止使用CSS表达式，fixed例外	
* [error] 文件夹和文件命名全部用小写字母且不存在ad连续字符，单词分隔用中横线，其中文件夹只有需要版本区分时才可用中横分隔，如fdev-v3	
* [error] 发布上线的文件需要压缩，命名规则如a.js->a-min.js，且两者在同一目录下	
* [skip] z-index的使用符合以下规则：头部1000至2000，内容区1000以下	
* [skip] 产品线级merge文件只能merge下列文件：lib文件、sys文件、所在综合线global文件、所在综合线module文件、所在综合线widget文件、本产品线module文件、本产品线widget文件	
* merge文件写法正确，详见合并脚本规则	
* [skip] 页面级merge文件只能merge下列文件：lib文件、sys文件、所在综合线global文件、所在综合线module文件、所在综合线widget文件、本产品线module文件、本产品线widget文件、本产品线page同名文件	
* [skip] 功能文件头部必须有注释，且包含时间、作者、项目信息，更新后需要加上更新注释，包含时间、作者、更新内容	
* [skip] 副logo字体依次取微软雅黑、黑体、文泉驿正黑体、华文细黑	
* [skip] 禁止在sys目录下放置merge文件	
* [skip] 产品线global目录下只放置该产品线级merge文件	

## html

* [fatal] 标签必须嵌套正确
* [error] 不能定义内嵌样式style
* [error] 避免重复引用*同一*或相同功能文件	**如何判断相同功能文件**
* [error] img标签加上alt属性	
* [error] 标签全部小写
* [error] 属性名全部小写
* [error] a标签加上title属性，除非作为功能点的a标签	
* [error] 必须存在文档类型声明
* [error] 必须使用大写的"DOCTYPE"
* [error] id、class名称全部小写，单词分隔使用中横线	
* [error] 不通过@import在页面上引入CSS	
* [error] 属性值使用双引号
* [error] 不能仅有属性名
* [error] head必须包含字符集meta和title	
* [error] 行内标签不得包含块级标签，a标签例外
* [error] text、radio、checkbox、textarea、select必须加name属性	
* [error] 所有按钮必须用button（button/submit/reset）	
* [error] 一个节点上定义的class个数最多不超过3个(不含lib中的class: fd- w952 layout grid)	
* [error] 标签必须闭合
* [warn] 功能a必须加target="\_self"，除非preventDefault过	**如何判断功能a** href !~ http
* [warn] 新页面统一使用HTML 5 DTD
* [warn] 外链CSS置于head里(例外：应用里的footer样式)
* [warn] 新页面按库中的HTML基本结构模板书写基本页面结构
* [skip] 页面必须引用fdev css	**urlx3:** 
* [skip] 外链产品线级js置于head，页面级js置于页底	
* [skip] h类标签层次分明，递减 

## js

* [fatal] 关键字和保留字不能作为变量名	
* [error] 所有语句结束带上分号	
* [error] 所有条件区域必须用花括号括起来	
* [error] 产品线级merge文件只能merge下列文件：lib文件、sys文件、所在综合线global文件、所在综合线module文件、所在综合线widget文件、本产品线module文件、本产品线widget文件	
* [error] merge文件写法正确，详见合并脚本规则	
* [error] 页面级merge文件只能merge下列文件：lib文件、sys文件、所在综合线global文件、所在综合线module文件、所在综合线widget文件、本产品线module文件、本产品线widget文件、本产品线page同名文件	
* [error] 使用命名空间，禁止出现不必要的全局变量	
* [error] 不允许使用eval	
* [error] 3个条件及以上的条件语句用switch代替if else	
* [error] 使用{}代替new Object()；使用[]代替new Array()	
* [warn] 合理使用===和!==操作符	
* [warn] try catch一般不允许嵌套，若嵌套，需要充分的理由	
* [warn] 功能文件头部必须有注释，且包含时间、作者、项目信息，更新后需要加上更新注释，包含时间、作者、更新内容	
* [warn] 发布上线的文件需要压缩，命名规则如a.js->a-min.js，且两者在同一目录下	
* [skip] 防止重复提交（form、ajax）	
* [skip] DOMReady之前不能进行DOM操作	
* [skip] onerror事件必须消除onerror事件	
* [skip] 不出现将造成线上bug的潜在js错误。此项为累计扣分，出现一次即扣相应分值，两次则扣两次，依此类推。但凡出现一次，均不予发布	
* [skip] 文件夹和文件命名全部用小写字母且不存在ad连续字符，单词分隔用中横线，其中文件夹只有需要版本区分时才可用中横分隔，如fdev-v3	
* [skip] 禁止在sys目录下放置merge文件	
* [skip] 产品线global目录下只放置该产品线级merge文件	
* [skip] 正确的缩进，最小缩进单位为4个空格	
* [skip] 无侵入式js，tracelog除外，有特例	
* [skip] 方法、变量都使用驼峰命名，类使用大驼峰(Pascal)命名	
* [skip] 变量声明应放在function的最上面，避免使用未声明的变量	
* [skip] 常量名全部大写，单词分隔使用下划线	
* [skip] on开头的命名只能用作事件处理函数	
* [skip] 初始化函数以init开头	
* [skip] Bolean类型变量必须以is/has等判断词开头，str开头的必须是字符串，arr开头的必须是数组，num开头的必须是数字，obj开头的必须是对象	
* [skip] 获取和配置参数的函数必须以get set开头	
* [skip] 重复变量从字母i开始依次往后定义	
* [skip] 私有变量和方法如果不在闭包中，则以下划线开头	
* [skip] 库、组件、代码片段中有的方法必须优先使用	
* [skip] 非特殊原因必须使用YUI，addClass/removeClass/getRegion例外	
* [skip] 按库中的js模板书写js	

