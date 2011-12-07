/**
 * @fileoverview 旺铺对话框
 *
 * @author qijun.weiqj
 */
(function($, WP){


var Dialog = new WP.Class({
	/**
	 * 对话框模板
	 */
	__$template:
		'<div class="d-body">\
			<% if (header) { %>\
			<div class="d-header">\
				<h3><%= header %></h3>\
				<% if (hasClose) { %>\
				<a class="d-close" href="#"></a>\
				<% } %>\
			</div>\
			<% } %>\
			<div class="d-content">\
				<%= content %>\
			</div>\
			<% if (hasFooter) { %>\
			<div class="d-footer">\
				<div class="d-confirm-loading"></div>\
				<div class="d-btn-wrap">\
				<% foreach (buttons as button) { %>\
					<a href="#" class="<%= button["class"] %>" href="javascript:;">\
						<span><%= button.value %></span>\
					</a>\
				<% } %>\
				</div>\
			<% } %>\
			</div>\
		</div>',

	/**
	 * 对话框构造函数
	 * @param {object} config
	 * - header {string} 对话框标题
	 * - center {boolean} 是否居中, 默认为true
	 * - hasClose {boolean} 是否具有关闭按扭, 默认为true
	 * - content {string|function(callback(html))} 对话框内容, 可以是一个回调函数
	 * - buttons {array<{ 'class': {string}, 'value': {string} }>} 对话框按扭
	 * - hasFooter {boolean} 是否有底栏
	 *
	 * - width: {number} 宽度
	 * - height: {number} 高度
	 * - centerFooter: {boolean} 是否居中底部 
	 *
	 * - contentUrl {string} 异步载入对话框内容, 需要提供URL
	 * - ajaxParams {object} 异步载入对话框内容时, ajax参数
	 * - contentParams {object} 同上(兼容)
	 * - contentSuccess {function(this)} 异步载入对话框后回调函数
	 *
	 * - defaultClassName {string} 默认对话框样式, 默认为wp-dialog
	 * - className {string} 对话框样式
	 *
	 * - draggable {boolean|object} 是否支持拖动, 默认不支持
	 * - handler {string} 拖动热区
	 * - beforeClose {function(this)} 对话框关闭前调用
	 * - close {function(this)} 如果存在"关闭(.d-close)"按扭, 单击此按扭时, 调用此方法
	 * - cancel {function(this)} 如果存在"取消(.d-cancel)"按扭, 单击此按扭时, 调用此方法
	 * - confirm {function(this)} 如果存在"确定(.d-confirm)"按扭, 单击此按扭时, 调用此方法
	 *
	 */
	init: function(config) {
		config = this.config = $.extend({
			header: false,
			center: true,
			hasClose: true,
			buttons: []
		}, config);

		// 初始化静态内容配置
		var content = config.content;
		if (typeof content !== 'string') {
			config.content = '<div class="d-loading">正在加载...</div>';
			this.__$contentLoader = content;
		}

		// 如果没有按扭, 则不需要显示footer
		config.hasFooter === undefined &&
				(config.hasFooter = !!config.buttons.length);

		// 如果有contentUrl则使用ajaxContentCallback
		if (config.contentUrl) {
			this.__$contentLoader = $.proxy(this, '__$ajaxContentLoader');
		}

		this.__$loadTemplate($.proxy(this, '__$openDialog'));
	},

	/**
	 * 异步载入对话框内容
	 */
	__$ajaxContentLoader: function(callback) {
		var config = this.config,
			error = function() {
				// 载入失败
				callback(false);
			},
			options = $.extend({
				cache: false
			}, config.ajaxParams);

		options.data = options.data || config.contentParams;

		$.extend(options, {
			success: function(html){
				// 当服务器返回空或整个html页面(302跳转)时, 当作错误处理
				if (!html || /<html[^>]*>/i.test(html)) {
					error();
					return;
				}
				callback(html);
			},
			error: error
		});

		$.ajax(config.contentUrl, options);
	},

	/**
	 * 生成template, 然后调用callback
	 * 由于dialog使用的地方可能没有载入web-sweet库(前台页面), 所以采用use动态加载
	 */
	__$loadTemplate: function(callback) {
		var self = this,
			tpl = Dialog._template;
		if (tpl) {
			return callback(tpl);
		} else if (true) {
        
    } else if (true) {
        
    } else {
        
    }

		$.use('web-sweet', function() {
			var tpl = Dialog._template = FE.util.sweet(self.__$template);
			callback(tpl);
		});
	},

	/**
	 * 显示对话框
	 * 动态加载ui-dialog
	 * 如果需要拖动, 则动态加载 ui-draggable
	 */
	__$openDialog: function(tpl) {
		var self = this,
			config = this.config,
			node = null,
			use = ['ui-dialog'];

		node = this.node = $('<div>').html(tpl.applyData(config));
	
		this.__$configNode(node, config);

		if (config.beforeOpen && config.beforeOpen(this) !== false) {
			return;
		}

		// 如果需要支持拖动, 则载入拖动库
		if (config.draggable) {
			use.push('ui-draggable');
		}

		$.use(use, function() {
			node.dialog(self.__$getDialogConfig(config));
			self.__$handleEvents();

			// 需要异步载入对话框内容
			if(self.__$contentLoader){
				self.__$loadContent();
			} else {
				self.__$contentSuccess();
			}
		});
	},

	__$configNode: function(node, config) {
		node.addClass((config.defaultClassName || 'wp-dialog') + 
				' ' + (config.className || ''));

		config.width && $('div.d-body', node).css('width', config.width);
		config.height && $('div.d-loading', node).css({
			height: config.height,
			'line-height': config.height
		});

		config.centerFooter && $('div.d-footer', node).addClass('align-center'); 
	},

	/**
	 * 取得对话框配置信息
	 */
	__$getDialogConfig: function(config) {
		var self = this,
			ret = {
				shim: true,
				center: config.center
			},
			draggable = config.draggable;

		if (draggable) {
			ret.draggable = $.isPlainObject(draggable) ?
					draggable : { handle: 'div.d-header' };
		}

		if (config.beforeClose) {
			ret.beforeClose = function() {
				return config.beforeClose(self);
			};
		}
		return ret;
	},

	/**
	 * 处理对话框按扭事件
	 */
	__$handleEvents: function() {
		this.__$handleBtnEvents();
		this.__$handleDefaultEvents();
	},

	/**
	 * 处理close,cancel,confirm的事件
	 */
	__$handleBtnEvents: function() {
		var self = this,
			config = this.config,
			node = this.node;
		
		$.each(['close', 'cancel', 'confirm'], function(i, op) {
			$('.d-' + op, node).bind('click', function(e) {
				e.preventDefault();
				var elm = $(this);
				if (elm.data('dialog-running')) {
					return;
				}
				
				elm.data('dialog-running', true);
				setTimeout(function() {
					elm.data('dialog-running', false);
				}, 500);
				
				config[op] ? config[op](self) : self.close();
			});
		});
	},
				   
	/**
	 * 处理默认按扭事件
	 */
	__$handleDefaultEvents: function() {
		var self = this,
			btn = $('.d-default', this.node).eq(0);
		
		if (!btn.length) {
			return;
		}
		
		// 用于关闭对话框时移除事件
		this.__$defaultEventHandler = function(e) {
			if (e.keyCode === 13) {
				btn.click();
				return false;
			}
		};
		$(document).bind('keydown', this.__$defaultEventHandler);
	},

	/**
	 * 异步载入对话框内容
	 */
	__$loadContent: function(loader){
		var self = this,
			config = this.config,
			container = this.getContainer(),
			loader = loader || this.__$contentLoader;
		
		loader(function(html) {
			html = html || '<div class="d-error">网络繁忙，请刷新后重试</div>';
			container.html(html);
			self.__$contentSuccess();
		});
	},

	__$contentSuccess: function() {
		var self = this,
			config = this.config;

		if (!config.contentSuccess) {
			return;
		}

		$.util.ua.ie6 ? setTimeout(function() {
			config.contentSuccess(self);
		}, 0) : config.contentSuccess(this);
	},

	/**
	 * 重新异步载入对话框
	 */
	reload: function(loader) {
		return this.__$loadContent(loader);
	},

	/**
	 * 设置对话框标题
	 */
	setTitle: function(title) {
		$('d-header h3', this.node).text(title);	
	},
		
	/**
	 * 设置对话框内容
	 */
	setContent: function(html) {
		this.getContainer().html(html);
	},

	/**
	 * 取得对话框内容容器
	 */
	getContainer: function() {
		if (!this.__$container) {
			this.__$container = $('div.d-content', this.node);
		}
		return this.__$container;
	},
			
	/**
	 * 关闭对话框
	 */
	close: function() {
		this.__$defaultEventHandler &&
				$(document).unbind('keydown', this.__$defaultEventHandler);
		return this.node.dialog('close');
	},

	submit: function() {
		this.config['confirm'] && this.config['confirm'](this); 
	},
	   
	/**
	 * 显示对话框loading图标
	 * @param {string|boolean} text
	 * TOOD 此方法期望重构成更加通用
	 */
	showLoading: function(text){
		var self = this,
			node = this.node,
			loading = $('div.d-confirm-loading', node),
			btnWrap = $('div.d-btn-wrap', node),
			confirm = $('a.d-confirm', node);
		
		if (text === false) {
			loading.hide();
			btnWrap.show();
		} else {
			loading.html(text);
			btnWrap.hide();
			loading.show();
		}
	}
});
//~Dialog


Dialog.open = function(config) {
	return new Dialog(config);
};


WP.widget.Dialog = Dialog;
$.add('wp-dialog');


})(jQuery, Platform.winport);

