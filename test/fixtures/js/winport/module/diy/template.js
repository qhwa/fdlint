/**
 * 旺铺DIY模板操作
 * @author qijun.weiqj
 */
(function($, WP) {


var Dialog = WP.widget.Dialog,
	Diy = WP.diy.Diy,
	Msg = WP.diy.Msg,
	Component = WP.diy.Component;

	
var DiyTemplate = {

	/**
	 * 应用模板
	 *
	 * 此方法信赖后端 “应用模板” 和 ”取得diy页面内容” 两个接口
	 * “应用模板”url地址信息配置在#doc[data-doc-config]上, 名称为: applyTemplateUrl
	 * "取得diy页面内容" url地址信息配置在#doc[data-doc-config]上，名称为: getDiyPageContentUrl 
	 *
	 * 异常处理：如果多次调用此接口, 若上一次没有返回则忽略本次调用
	 *
	 * @param {object} template  模板信息
	 * 	- templateKey 模板标识
	 * 	- skinUrl 皮肤样式文件地址
	 * 	- customStyles {array<{subject, isEnable, styleContent}>}
	 *
	 * @param {object} options (可选)
	 * 	- success {function()}应用成功后回调函数
	 * 	- error {function()} 应用失败后回调函数
	 */
	apply: function(template, options) {
		if (this._running) {
			return;	
		}

		var self = this;

		options = this._prepareOptions(options);

		this._showLoading('正在应用模板，请稍候...'); 

		this._applySkin(template.skinUrl);
		this._applyCustomStyles(template.customStyles || []);

		this._postApply(template.templateKey, {
			success: function(ret) {
				self._postApplySuccess(ret, options);
			},
			
			error: function(message) {
				self._hideLoading();

				self._restoreCustomStyles();
				self._restoreSkin();

				Msg.error(message);
				options.error();
			}
		});
	},

	/**
	 * 应用皮肤css文件到旺铺
	 */
	_applySkin: function(skinUrl) {
		if (!skinUrl) {
			return;
		}

		var link = $('#skin-link'),
			last = link.attr('href');
			
		if (last === skinUrl) {
			return;
		}
		
		link.attr('href', skinUrl);
		this._lastSkinUrl = last;
	},

	/**
	 * 恢复先前皮肤css
	 */
	_restoreSkin: function() {
		var link = $('#skin-link'),
			last = this._lastSkinUrl;

		if (last) {
			link.attr('href', last);
			this._lastSkinUrl = null;	
		}
	},

	/**
	 * 应用用户自定义样式到旺铺
	 */
	_applyCustomStyles: function(styles) {
		var link = $('#custom-style'),
			css = [];

		$.each(styles, function() {
			var style = this;
			(style.isEnable || style.enabled) && css.push(style.styleContent);
		});	

		this._lastCustomStyles = link.html();
		link.html(css.join('\n'));	
	},

	/**
	 * 恢复上一次用户自定义样式
	 */
	_restoreCustomStyles: function() {
		var link = $('#custom-style'),
			last = this._lastCustomStyles;
		
		if (last) {
			link.html(last);
			this._lastCustomStyles = null;	
		}
	},

	/**
	 * 请求后台“应用模板”
	 */
	_postApply: function(templateKey, options) {
		var self = this,
			docCfg = Component.getDocConfig(),
			url = docCfg.applyTemplateUrl,
			data = {
				templateKey: templateKey
			};

		url = 'mock.json';

		if (!url) {
			throw new Error('please specify applyTemplateUrl');
		}

		Diy.authAjax(url, {
			type: 'POST',
			dataType: 'json',
			data: data,

			success: function(ret) {
				if (ret.success) {
					options.success(ret);	
				} else {
					options.error('应用模板失败，请刷新后重试');
				}
			},

			error: function() {
				options.error('网络繁忙，请刷新后重试');
			}
		});
	},

	_postApplySuccess: function(ret, options) {
		var self = this,
			success = function() {
				self._hideLoading();
				
				Msg.info('应用模板成功');
				options.success();
			};
		
		ret.needReload ? this._reloadPageContent(success) : success();
	},

	/**
	 * 重新载入旺铺内容区，以反映最近模板的应用
	 */
	_reloadPageContent: function(success) {
		var docCfg = Component.getDocConfig(),
			url = docCfg.getDiyPageContentUrl,
			error = function() {
				window.location.reload();
			};

		url = 'mock.htm';

		if (!url) {
			throw new Error('please specify getDiyPageContentUrl');	
		}

		$.ajax(url, {
			type: 'GET',
			success: $.proxy(this, '_reloadPageContentSuccess', success, error),
			error: error 
		});
	},

	_reloadPageContentSuccess: function(success, error, html) {
		if (!html || /<html[^>]*>/i.test(html)) {
			error();
			return;
		}

		$('#content').html(html);
		WP.ModContext.refresh();

		$(window).trigger('pagecontentreload');
		$.log('pagecontentreload');
		success();
	},

	/**
	 * 备份当前旺铺
	 *
	 * "备份"接口url地址配置在#doc[data-doc=config]上，名称为: backupTemplateUrl
	 *
	 * 异常处理: 如果多次调用此接口，若上一次没有返回，则忽略本次调用
	 *
	 * @param {object} options  (可选)
	 *  - success {function()}   备份成功后回调函数
	 *  - error {function()}  备份失败后回调函数
	 */
	backup: function(options) {
		if (this._running) {
			return;	
		}

		var self = this,
			docCfg = Component.getDocConfig(),
			url = docCfg.backupTemplateUrl,
			data = {};

		if (!url) {
			throw new Error('please specify backupTemplateUrl');
		}

		options = this._prepareOptions(options);

		this._showLoading('正在备份，请稍候...');

		Diy.authAjax(url, {
			type: 'POST',
			dataType: 'json',
			data: data,

			success: function(ret) {
				self._hideLoading();

				if (ret.success) {
					Msg.info('备份模板成功');
					options.success();		
				} else {
					Msg.error('备份模板失败，请刷新后重试');
					options.error();
				}
			},

			error: function() {
				self._hideLoading();
				Msg.warn('网络繁忙，请刷新后重试');
				options.error();
			}
			
		});
	},

	_prepareOptions: function(options) {
		options = options || {};
		options.success = options.success || $.noop;
		options.error = options.error || $.noop;
		return options;
	},

	/**
	 * 显示loading对话框(只有整个操作>100ms时才显示对话框)
	 */
	_showLoading: function(message) {
		this._running = true;
		this._loadingDialog = new Dialog({
			className: 'template-loading-dialog',
			content: '<div class="d-loading">' + message + '</div>'
		});

	},

	/**
	 * 隐藏loading对话框
	 */
	_hideLoading: function() {
		this._running = false;
		this._loadingDialog.close();	
	}

};


WP.diy.Template = DiyTemplate;

	
})(jQuery, Platform.winport);

