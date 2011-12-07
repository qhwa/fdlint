/**
 * @fileoverview 后台DIY mod-box公共操作
 * 
 * @author qijun.weiqj
 */
(function($, WP) {
	
var ModContext = WP.ModContext,
	Component = WP.diy.Component,
	FormDialog = WP.diy.FormDialog;


/**
 * 请求和重新载入板块
 */
var Loader = {
	
	/**
	 * 重新载入一个ModBox
	 * @param {element} box
	 * @param {function(box)} callback 回调方法
	 */
	reload: function(box, callback) {
		if (box.length === 0) {
			$.error('assert false: box empty');
		}

		var self = this,
			elm = box[0],
			region = box.closest('div.region'),
			boxCfg = box.data('boxConfig'),

			// 用于防止同时多次请求
			lastAction = box.data('reloadAction'),

			complete = function() {
				box.removeData('reloadAction');
			};
		
		lastAction && lastAction.abort();

		box.trigger('beforereload');
		lastAction = this.request({
			region: region.data('regionConfig').cid,
			cid: boxCfg.cid,
			sid: boxCfg.sid,
			
			success: function(newBox, html) {
				self._reloadSuccess(box, html, function() {
					complete();
					callback && callback();
				});
			},
			
			error: complete
		});
		
		box.data('reloadAction', lastAction);
	},

	_reloadSuccess: function(box, html, callback) {
		var pattern = /<div[^>]*>([\s\S]+)<\/div>/,
			match = pattern.exec(html);
				
		if (!match) {
			$.error('assert false: response html must contain in div.mod-box');
		}

		box.trigger('reloading');
		box.html(match[1]);
		ModContext.refresh($('div.mod', box));
		box.trigger('reloaded');
		
		callback();
	},

	
	/**
	 * 请求一个ModBox
	 * @param {object} options
	 * 	- region regionId
	 *  - cid
	 *  - sid
	 *  - success {function(box)}
	 *	- error
	 */
	request: function(options) {
		var contentCfg = Component.getContentConfig(),
			url = contentCfg.getBoxUrl;
			
		return $.ajax(url, {
			cache: false,
			data: {
				pageSid: contentCfg.sid,
				pageCid: contentCfg.cid,
				region: options.region,
				cid: options.cid,
				sid: options.sid
			},
			
			success: function(html) {
				// 当html中包含script时, 构造出的jquery对象会包含多个节点 
				// 所以使用request的同学需要注意
				// @see list-panel.js loadModBox
				var box = $(html).eq(0);
				if (box.is('div.mod-box')) {
					options.success(box, html);
				} else {
					options.error && options.error();
				}
			},
			
			error: options.error
		});
	},

	/**
	 * 载入新添加的板块
	 * @param options
	 *	- cid
	 *	- sid
	 *	- region
	 *	- index
	 *
	 *	- success
	 *	- error
	 */
	load: function(options) {
		var region = options.region,
			index = options.index;
		
		this.request({
			region: region.data('regionConfig').cid,
			cid: options.cid,
			sid: options.sid,
			success: function(box, html) {
				box = $(html);	// 根据html重新构造box(因为html里可能含有js, 所以box可能包含多个节点)
				if (index === 0) {
					region.prepend(box);
				} else {
					$('div.mod-box', region).eq(index - 1).after(box);
				}

				box = box.eq(0);　//　在插入到页面后, 过滤掉其他非mod-box节点 
				ModContext.refresh($('div.mod', box));

				options.success && options.success(box, html);

				box.trigger('loaded');
			},

			error: options.error 
		});
	}
};
//~


/**
 * 板块编辑
 */
var Editor = {

	/**
	 * @param {jquery} box 一个mod-box节点的jquery对象
	 */
	edit: function(box, callback) {
		var boxCfg = box.data('boxConfig');

		if(!boxCfg.editable ||
				$(window).triggerHandler('boxbeforeedit', { element: box[0] }) === false) {
			return false;
		}
		
		var self = this,
			editCfg =  box.data('editConfig'),
			script = editCfg.script[0],
			handlerName = script ? this._getHandler(script) : 'DefaultHandler',
			
			open = function() {
				self._openDialog(box, boxCfg, editCfg, handlerName);
				callback && callback();
			};
			
		if (WP.diy.form[handlerName]) {
			open();
			return;
		}

		$.log('loading ' + handlerName);
		$.ajax(script, {
			dataType: 'script',
			cache: false,
			success: open
		});
	},

	_openDialog: function(box, boxCfg, editCfg, handlerName) {
		var handler = WP.diy.form[handlerName],
			className = this._getDialogClassName(box) + ' ' + 
				this._getDialogHandlerClassName(handlerName),

			config = {
				buttons: [
					{ 'class': 'd-confirm', value: '确定' },
					{ 'class': 'd-cancel', value: '取消' }
				],
			
				header: '设置板块：' + editCfg.widgetName,
				className: className.trim(),
				draggable: true,
				contentUrl: editCfg.editFormUrl,
				ajaxParams: {
					type: 'POST',
					data: { cid: boxCfg.cid }
				},
				handler: handler,
				handlerName: handlerName,
				formData: box
			};
		
		handler.getFormConfig && $.extendIf(config, handler.getFormConfig(box));
		FormDialog.open(config);
	},
	
	_getDialogClassName: function(box) {
		var modId = this._getModId(box);
		return modId ? modId + '-form-dialog ' : ''; 
	},

	_getDialogHandlerClassName: function(name) {
		return name.replace(/[A-Z]/g, function(r) {
			return '-' + r.toLowerCase();
		}).replace(/^-/, '') + '-dialog';
	},
	
	_getModId: function(box) {
		var mod = $('div.mod', box),
			cns = (mod[0].className || '').split(/\s+/),
			cn = cns[1] || '';	// 取第二个class
		return cn.replace(/^\w+-/, ''); // 去前缀
	},

	/**
	 * 根据文件路径, 取得Handler名称
	 * 	例 .../form/company-name-handler.js -> CompanyNameHandler
	 */
	_getHandler: function(script) {
		var name = script && (/([^\/]+)\.js$/.exec(script) || {})[1];
		if (!name) {
			return null;
		}
		name = name.replace(/[-_](\w)/g, function(r, m) {
			return m.toUpperCase();
		});
		return name.substr(0, 1).toUpperCase() + name.substr(1);
	}
};
//~


/**
 * 添加板块
 */
var Adder =  {
	/**
	 * @param options
	 *	- cid
	 *	- region
	 *	- index

	 *	- success
	 *	- error
	 */
	add: function(options) {
		this._validate(options) &&
				this._doAdd(options);
	},

	_validate: function(options) {
		var contentCfg = Component.getContentConfig(),
			maxCount = contentCfg.maxCount,
			boxes = $('#content div.mod-box'),
			count = 0;
		boxes.each(function() {
			var config = $(this).data('boxConfig');
			config && config.deletable && count++;
		});
		if (maxCount > 0 && count >= maxCount) {
			options.error && options.error($.util.substitute('最多可添加{0}个板块，添加板块失败', [maxCount]));
			return false;
		}
		return true;
	},

	_doAdd: function(options) {
		var self = this,
			contentCfg = Component.getContentConfig(),
			url = contentCfg.addWidgetUrl;
		
		$.ajax(url, {
			type: 'POST',
			dataType: 'json',
			data: this._getData(options),
			
			success: $.proxy(this, '_success', options),
			error: $.proxy(this, '_error', options) 
		});
	},

	_getData: function(options) {
		var contentCfg = Component.getContentConfig(),
			region = options.region;

		return $.extendIf({
			cid: options.cid,
			version : contentCfg.version,
			index: options.index
		}, Component.getRegionPostData(options.region));
	},

	_success: function(options, o) {
		var contentCfg = Component.getContentConfig();
		if (o.success) {
			++contentCfg.version;
			Loader.load({
				cid: options.cid,
				sid: o.data,
				region: options.region,
				index: options.index,

				success: function(box) {
					$(window).trigger('diychanged', { type: 'add-box', box: box });
					options.success(box);
				},
				error: function() {
					options.error && options.error('载入板块失败，请刷新后重试');
				} 
			});
		} else if (o.data === 'VERSION_EXPIRED') {
			window.location.reload();
		} else {
			this._error(options);
		}
	},

	_error: function(options) {
		options.error && options.error('添加板块失败，请刷新后重试');
	}

};
//~


/**
 * 导出api
 */
WP.diy.ModBox = {
	
	reload: $.proxy(Loader, 'reload'),
	request: $.proxy(Loader, 'request'),
	load: $.proxy(Loader, 'load'),

	edit: $.proxy(Editor, 'edit'),
	add: $.proxy(Adder, 'add')

};


})(jQuery, Platform.winport);
