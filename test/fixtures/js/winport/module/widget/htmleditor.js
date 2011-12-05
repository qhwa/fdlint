/**
 * @fileoverview 编辑器
 * @author qijun.weiqj
 */
(function($, WP) {

var HtmlEditorConfig = {
	// General options
	mode: 'exact',      //编辑器使用的数据源来自textarea
	theme: 'advanced',  //编辑器的基础功能配置为advanced
	skin: 'aliRTE',     //编辑器皮肤aliRTE
	//以上三项请在没有必要时不要随意改动
	//plugins为编辑器加载的插件配置，删除plugins中的插件会自动删除相关的按钮，但是删除工具栏的按钮并不会删除相关功能
	//plugins中以ali开头的插件名为aliRTE特制插件，相关的配置项会在后面描述
	plugins: 'contextmenu,aliwindow,paste,table,aliCCBUImage,advlink,aliFilter,aliGroup,aliViewAndCode,aliResize,aliTracelog,aliMultiLanguage',
	
	//编辑器大小配置
	width: 600,
	height: 350,
	
	// Theme options
	//编辑器工具栏配置，theme_advanced_buttons1代表工具栏第一行，theme_advanced_buttons2代表工具栏第二行
	//在工具栏中删除按钮并不会删除相关功能，譬如删除table按钮，在鼠标右键菜单中将仍然可以看到“插入编辑表格”的功能
	//按钮中出现的group按钮为下拉按钮组合，对因aliGroup插件，相关的配置请见49行
	theme_advanced_buttons1: 'image,table,module',
	theme_advanced_buttons2: 'undo,fontselect,fontsizeselect,forecolor,backcolor,|,bold,italic,underline,strikethrough,group,|,justifyleft,justifycenter,justifyright,|,group,group,|,charmap,|,link,unlink',
	theme_advanced_buttons3: '',
	theme_advanced_toolbar_location: 'top', //工具栏设置在编辑器顶部
	theme_advanced_toolbar_align: 'left', //工具栏中按钮对齐方式为左对齐
	theme_advanced_statusbar_location: 'bottom', //状态栏设置在编辑器底部
	//编辑器文字大小自定义配置，默认为"1,2,3,4,5,6,7"
	//配置方法为“显示文案=大小”，如“一号=26pt;小一=24pt”
	//注意：为了保证在utf-8和gb2312等不同编码的页面中都可以正常显示汉字，这里的汉字都做了unicode编码，如：“一号”为“\u4E00\u53F7”
	theme_advanced_font_sizes: '\u4E00\u53F7=26pt;\u5C0F\u4E00=24pt;\u4E8C\u53F7=22pt;\u5C0F\u4E8C=18pt;\u4E09\u53F7=16pt;\u5C0F\u4E09=15pt;\u56DB\u53F7=14pt;\u5C0F\u56DB=12pt;\u4E94\u53F7=10pt;\u5C0F\u4E94=9pt;\u516D\u53F7=7.5pt;\u5C0F\u516D=6.5pt;\u4E03\u53F7=5.5pt;\u516B\u53F7=5pt',
	//编辑器文字字体自定义配置，默认为英文字体，因此在中文环境下，请务必配置此项
	//配置方法为“显示文案=字体”，如“宋体=simsun;黑体=simhei”
	//注意：为了保证在utf-8和gb2312等不同编码的页面中都可以正常显示汉字，这里的汉字都做了unicode编码，如：“宋体”为“\u5B8B\u4F53”
	theme_advanced_fonts: '\u5B8B\u4F53=simsun;\u9ED1\u4F53=simhei;\u6977\u4F53=\u6977\u4F53_GB2312;\u96B6\u4E66=\u96B6\u4E66;\u5E7C\u5706=\u5E7C\u5706;\u4EFF\u5B8B=\u4EFF\u5B8B_GB2312;\u5FAE\u8F6F\u96C5\u9ED1=\u5FAE\u8F6F\u96C5\u9ED1',
	//配置是否允许编辑器变化大小
	theme_advanced_resizing: true,
	
	
	//编辑器语言配置
	//简体中文：cn
	//繁体中文：zh
	//英文：en
	language: 'cn',
	
	//第几行Toolbar为特殊行，无特殊行('0')
	strongToolbar: '1',
	
	//特殊功能Button样式引入
	strong_Button: {
	    'image': ['aliButtonS btn-f-left', 'aliButtonS btn-f-left aliButtonSmo'],
	    'table': ['aliButtonS btn-f-left', 'aliButtonS btn-f-left aliButtonSmo'],
	    'module': ['aliButtonS btn-f-left', 'aliButtonS btn-f-left aliButtonSmo']
	},
	
	//aliGroup Config
	//下拉组合按钮插件配置项
	//group_set为对象数组，每个对象对应一个组合按钮，数组的长度和工具栏按钮配置中的"group"数量必须相同
	//每个对象中icon为组合按钮显示的图标，buttons为功能按钮组合
	//title为工具集的title
	group_set: [
	    {
	        title: '\u4E0A\u4E0B\u6807',
	        icon: '/themes/advanced/skins/aliRTE/img/icon-sup.gif',
	        buttons: 'sup,sub',
	        tracelog: 'topmark,submark'
	    }, {
	        title: '\u7F16\u53F7',
	        icon: '/themes/advanced/skins/aliRTE/img/icon-bullist.gif',
	        buttons: 'bullist,numlist',
	        tracelog: 'projectnum,digitalnum'
	    }, {
	        title: '\u7F29\u8FDB',
	        icon: '/themes/advanced/skins/aliRTE/img/icon-indent.gif',
	        buttons: 'indent,outdent',
	        tracelog: 'addindent,subindent'
	    }
	],
	
	//aliCount Config
	//编辑器字符数限制
	textTotal: 50000,
	
	//aliResize config
	//编辑器大小变化配置，分别为最大高度，最小高度，步进高度
	resize_set: {
	    maxHeight: 1500,
	    minHeight: 500,
	    stepHeight: 200
	},
	
	//aliTracelog Config
	//编辑器被加载时发送的tracelog
	tracelog: 'wpdiy_aliRTE',
	
	//i18n Rewrite Config
	//自定义文案配置，具体配置方案请参照custom_i18n.docx
	custom_i18n: {
	    'cn.aliResize': {
	        isLargest: '\u7F16\u8F91\u5668\u5DF2\u7ECF\u662F\u6700\u5927\u4E86',
	        isSmallest: '\u7F16\u8F91\u5668\u5DF2\u7ECF\u662F\u6700\u5C0F\u4E86'
	    },
	    'en.advlink_dlg': {
	        msginfo: 'You can insert all links.',
	        errorMsg: 'URL permission denied'
	    },
	    'cn.aliimage': {
	        validFailNotLogin: '\u60A8\u9700\u8981\u767B\u5F55\u624D\u53EF\u4EE5\u4E0A\u4F20\u56FE\u7247',
	        validFailNormal: '\u62B1\u6B49\uFF0C\u670D\u52A1\u5668\u9519\u8BEF\uFF0C\u56FE\u7247\u4E0A\u4F20\u5931\u8D25\u3002',
	        availableDomainsInfo: '\u53EA\u5141\u8BB8\u63D2\u5165\u4EE5\u4E0B\u57DF\u540D\u4E0B\u7684\u56FE\u7247\uFF08{#domain}\uFF09',
	        validFailInvalidDomain: '\u56FE\u7247\u5730\u5740\u4E0D\u5408\u6CD5\uFF0C\u8BF7\u91CD\u65B0\u8F93\u5165'
	    }
	},
	
	//table config
	//插入编辑表格配置项
	table_default_border: 1, //表格默认边框
	table_default_width: '680', //表格默认宽度
	table_default_class: 'aliRTE-table', //表格默认className，没有必要请不要修改
	table_col_limit: 12, //表格最大列数
	table_row_limit: 128, //表格最大行数
	//link config
	//插入编辑链接配置项
	link_config: {
	    allow_all: false, //是否允许所有外部链接
	    is_ali_only: false, //是否只允许阿里巴巴旗下域名的链接
	    white_list: [ //可使用的外部链接白名单
	        '*.aliui.com', '*.aliued.com'
	    ]
	},
	
	//ali-image-insert config
	//插入编辑图片配置项
	aliimage_config: {
	    //是否允许所有外部图片链接
	    allow_all: true,
	    //是否只允许阿里巴巴旗下域名的图片链接
	    is_ali_only: false,
	    //图片类型限制
	    fileTypes: '',
	    //一次可上传的图片张数限制
	    fileCountLimit: 10,
	    allowUpload: true,
	    allowAlbum: true,
	    allowWeb: true,
	    allow_all: true,
	    is_ali_only: false,
	    uploadVars_flash: { source: 'offer_biz' },
	    uploadVars_html: { source: 'offer_biz' },
	    //插入本地图片-需要进行压缩的图片大小
	    compressSize: 5 * 1024 * 1024,
	    compressWidth: 1024,
	    compressHeight: 1024,
	    compressQuality: 93,
	    //在此大小范围内的图片都会传输到服务器
	    uploadSizeLimit: 1 * 1024 * 1024,
	    //插入本地图片-压缩后运行上传的图片大小
	    sizeLimitEach: 640 * 1024,
	    //插入本地图片-上传图片的类型
	    supportFileTypes: ['jpg', 'jpeg', 'gif', 'bmp', 'png'],
	    //插入本地图片-一次上传图片的数量
	    fileCountLimit: 10,
	    fileFieldName: 'imgFile',
	    //上传地址
	    uploadUrl: '',
	    //验证地址
	    checkUrl: '',
	    //获取相册概要信息接口地址
	    fetch_summinfo_url: '',
	    //获取相册图片接口地址
	    fetch_piclist_url: '',
	    //获取相册列表接口地址
	    fetch_albumlist_url: '',
	    //将服务器返回的数据转换成需要的数据格式
	    response_to_result_object: function(data, str) {
	        var succ = data.result == 'success',
	        getString = function(s) {
	            if (!s) return ''; return typeof (s) == 'string' ? s : s[0];
	        },
	        errMsg = succ ? '' : getString(data.errMsg),
	        errCode;
	        switch (errMsg) {
	            case 'imgTooBig':
	            errCode = '1000';
	                break;
	            case 'maxImageSpaceExceed':
	                errCode = '1600';
	                break;
	            case 'maxImgPerAlbumExceeded':
	                errCode = '1700';
	                break;
	            case 'imgTypeErr':
	                errCode = '1100';
	                break;
	            default:
	                errCode = '1500';
	                break;
	        }
	        //1000 fail on file size check
	        //1100 fail on file type check
	        //1200 fail on token validation
	        //1300 fail on adding wartermark
	        //1400 fail on gererating thumbnails
	        //1500 unknown
	        //1600 max exceeded
	
	        return {
	            success: succ,
	            errorCode: errCode,
	            filePath: succ ? getString(data.imgUrls) : null,
	            thumb: succ ? getString(data.miniImgUrls) : null,
	            id: succ ? data.dataList[0] : null,
	            errMsg: errMsg
	        };
	    },
	    //图片前缀，非Arranda上传方式留空
	    imgPrefix: '',
	    fetch_piclist_url: '/album/ajax/image_detail_list.json',
	    fetch_albumlist_url: '/album/ajax/album_puller_ajax.json',
	    break_after_image: '<br/><br/>'
	},
	
	paste_retain_style_properties: 'color,background-color,font,font-size,font-weight,font-family,font-style,border-top,border-right,border-bottom,border-left,border-color,border-width,border-style',
	paste_auto_cleanup_on_paste: true,
	paste_block_drop: true,
	invalid_elements: 'script,link,iframe,frame,frameset,style,embed,object,html,head,body,meta,title,base,!DOCTYPE,applet,textarea,xml,param,code,form',
	extended_valid_elements: 'marquee[align|behavior|bgcolor|direction|height|width|hspace|vspace|loop|scrollamount|scrolldelay]',
	
	
	//Example content CSS (should be your site CSS)
	//在编辑器中引用外部CSS，以便达到所见即所得，让编辑器内的显示效果和发布后的现实效果保持一致
	content_css: '',
	
	// Drop lists for link/image/media/template dialogs
	template_external_list_url: '',
	external_link_list_url: '',
	external_image_list_url: '',
	media_external_list_url: '',
	
	// Replace values for the template plugin
	template_replace_values: {
	    username: 'Some User',
	    staffid: '991234'
	}
};
//~ HtmlConfig


$.getScript('http://style.china.alibaba.com/app/alirte/jscripts/tiny_mce/tiny_mce.js');


var Util = WP.Util;

var HtmlEditor = Util.mkclass({
	
	init: function(elm, config) {
		if (!HtmlEditor.isPrepared) {
			HtmlEditor.prepare();
		}

		this.elm = $(elm).eq(0);
		this.config = this._prepareConfig(config);

		this._initEditor();
	},
	
	_prepareConfig: function(config) {
		config = config || {};

		var ret = $.extend({}, HtmlEditorConfig);

		this.id = this._getEditorId();
		ret.elements = this.id;

		ret.aliimage_config = $.extend({}, ret.aliimage_config, {
			//上传地址
			uploadUrl: config.uploadUrl,
			
			//获取相册概要信息接口地址
			fetch_summinfo_url: config.fetchSummInfoUrl,
			
			//获取相册图片接口地址
			fetch_piclist_url: config.fetchPicListUrl,
			
			//获取相册列表接口地址
			fetch_albumlist_url: config.fetchAlbumListUrl,
			
			//获取相册图片数量接口
			fetch_piccount_url: config.fetchPicCountUrl,
			
			//新建相册接口
			add_album_url: config.addAlbumUrl
		});

		if (config.focus) {
			ret.auto_focus = this.id; 
		}
		
		return ret;
	},
	
	_getEditorId: function() {
		var elm = this.elm,
			id = elm.attr('id');
		if (!id) {
			id = 'html-editor-' + $.now();
			elm.attr('id', id);
		}
		return id;
	},
	
	_initEditor: function() {
		var config = this.config;
		tinyMCE.init(config);
	},
	
	/**
	 * 提交表单前, 需要调用update以同步编辑器内容到textarea
	 */
	update: function() {
		var editor = tinyMCE.get(this.id);
		editor.execCommand('beforeSubmit');
		editor.save();

		this._filterHTML();
	},

	_filterHTML: function(html) {
		var html = this.elm.val();
		html = html.replace(/<!--[^>]*-->/g, ''); // 编辑器会产生注释,重新解析注释时会报错,所以要过滤后再保存
		this.elm.val(html);
	},
	
	/**
	 * 关闭编辑器时，需要调用close以释放资源
	 */
	close: function() {
		if (this.isClosed) {
			return;
		}
		
		var editor = tinyMCE.get(this.id);
		editor.remove();
		editor.destroy();
		
		this.isClosed = true;
	},

	focus: function() {
		tinyMCE.execCommand('mceFocus', true, this.id);
	}
	
});


/**
 * 由于原先编辑器图片管家依赖于页面中的一些节点
 * 而这些节点在新旺铺中并不存在,
 * 所以为了能够让编辑器正常工作, 需要事先在页面中添加一些节点
 */
$.extend(HtmlEditor, {

	prepare: function() {
		if (this.isPrepared) {
			return;
		}

		var docCfg = $('#doc').data('doc-config'),
			html = [ 
				'<input id="has-album-value" type="hidden" value="true" />',
				'<input name="_csrf_token" type="hidden" value="{0}" />',
				'<input name="haswinport" type="hidden" value="true" />'
			].join('\n');

		html = $.util.substitute(html, [docCfg._csrf_token]);
		
		$('body').append(html);
		window.isTP = docCfg.isTP;

		this.isPrepared = true;
	}
});

//~ HtmlEditor

WP.widget.HtmlEditor = HtmlEditor;
$.add('wp-htmleditor');

	
})(jQuery, Platform.winport)
