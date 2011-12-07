/**
 * @fileoverview 旺铺招牌编辑对话框处理类
 *
 * @author qijun.weiqj
 */
(function($, WP){
	
var Msg = WP.diy.Msg,
	Util = WP.Util,
	UI = WP.UI,
	Tabs = WP.widget.Tabs,
	FormUtil = WP.widget.FormUtil,
	Diy = WP.diy.Diy,
	ImageUpload = WP.diy.ImageUpload,
	ModBox = WP.diy.ModBox,
	BaseHandler = WP.diy.form.BaseHandler;


/**
 * 普通招牌Handler
 */
var DefaultCompanyNameHandler = $.extendIf({
	
	/**
	 * 初始化, 由FormDialog自动调用
	 */
	init: function() {
		BaseHandler.init.apply(this, arguments);

		this.mod = $('div.default-sub-mod', this.box).eq(0);
		
		// 当前表单数据(提交失败, 或取消时需要使用)
		this.lastData = this._getData();
		
		this.docCfg = $('#doc').data('doc-config');
		
		this.name = 'CompanyNameHandler';
		Util.initParts(this);
	},

	getFormConfig: function(box) {
		return { width: '800px', height: '212px', centerFooter: true };
	},
	
	_afterSubmit: function(ret) {
		if (ret.success) {
			this.dialog.close();
			Msg.info('设置招牌成功');
		} else {
			Msg.error("设置招牌失败");
		}
	},

	
	/**
	 * 取消操作, 由FormDialog自动调用
	 */
	cancel: function() {
		var data = this.lastData;
		$('input.path', this.part).val(data.bgImgPath);
		this.updateMod(data);
	},
	
	/**
	 * 取得页面表单数据
	 */
	_getData: function() {
		var data = FormUtil.getFormData(this.form),
			check = $('input.topbanner-custom', this.form);
			
		data.isUseCustomTopBanner = check.prop('checked');

		return data;
	},

	_getFormData: function() {
		var data = this._getData();
		return this._wrapSubmitData(data);
	},
	
	/**
	 * 提交给后台时需要对getData返回的数据进行处理
	 *  - 图片url去host
	 */
	_wrapSubmitData: function(data) {
		var pattern = /^http:\/\/[^\/]+\//;
		data.bgImgPath = data.bgImgPath.replace(pattern, '');
		data.logoImgPath = data.logoImgPath.replace(pattern, '');
		return data;
	},
	
	/**
	 * 更新招牌样式, 数据招牌有变化时调用
	 * @param {object} data 样式数据
	 */
	updateMod: function(data) {
		data = data || this._getData();
		
		$.log(data);
		
		var mod = this.mod,
			logo = $('div.logo a', mod),
			logoImg = $('img', logo),
			chinaname = $('a.chinaname', mod),
			enname = $('a.enname', mod),
			
			bkImg = data.isUseCustomTopBanner && data.bgImgPath ? 
					'url(' + data.bgImgPath + ')' : '';
		
		// 触发板块更新事件
		this.mod.triggerHandler('updatemod', data);
		
		
		// 招牌背景色/背景图片
		mod.css({
			'background-image': bkImg,
			'background-repeat': bkImg ? 'repeat' : ''
		});
		
		// LOGO
		if (!logoImg.length) {
			logoImg = $('<img />').appendTo(logo);
		}
		if (data.logoImgPath) {
			logoImg.attr('src', data.logoImgPath).show();
			UI.resizeImage(logoImg, 80);
		} else {
			logoImg.hide();
		}
		
		// 中文名称样式
		chinaname.toggleClass('hidden', !data.isShowCompanyNameCn);
		chinaname.css({
			'color': data.companyNameCnFontColor,
			'font-family': data.companyNameCnFontFamily,
			'font-size': data.companyNameCnFontSize,
			'font-weight': data.isCompanyNameCnFontBold ? 'bold' : 'normal',
			'font-style': data.isCompanyNameCnFontItalic ? 'italic' : 'normal'
		});
		
		
		// 英文名称
		enname.toggleClass('hidden', !data.isShowCompanyNameEn);
		enname.css({
			'color': data.companyNameEnFontColor,
			'font-family': data.companyNameEnFontFamily,
			'font-size': data.companyNameEnFontSize,
			'font-weight': data.isCompanyNameEnFontBold ? 'bold' : 'normal',
			'font-style': data.isCompanyNameEnFontItalic ? 'italic' : 'normal'
		});
	},
	//~ updateMod
	
	
	/**
	 * 上传文件时, 需要包装的公共参数
	 */
	wrapUploadConfig: function(config) {
		return $.extend(config, {
			_csrf_token: this.docCfg._csrf_token,
			imageUploadUrl: this.config.imageUploadUrl,
			uid: this.docCfg.uid
		});
	}

}, BaseHandler);
//~ CompanyNameHandler


var Parts = (DefaultCompanyNameHandler.Parts = {});


/**
 * 招牌背景编辑部分
 */
Parts.TopbarPart = {
	
	init: function() {
		this.part = $('div.topbanner-part', this.form);
		this.initTabs();
		this.initImageUpload();
		this.handleUpdateMod();
	},
	
	/**
	 * 初始化招牌图片类型Tabs
	 */
	initTabs: function() {
		var self = this,
			tabs = $('ul.topbanner-tabs :radio', this.part),
			bodies = $('ul.topbanner-bodies li', this.part);
			
		tabs.click(function() {
			var index = tabs.index(this);
			bodies.removeClass('selected').eq(index).addClass('selected');
			self.updateMod();
		});
		
		tabs.filter(':checked').click();
	},
	
	/**
	 * 初始化图片上传flash组件
	 */
	initImageUpload: function() {
		var self = this,
			preview = $('div.preview', this.part);
		config = this.wrapUploadConfig({
			onUpload: function() {
				UI.resizeImage($('img', preview), { width: 360, height: 68 });
				self.updateMod();
				self.dialog.node.trigger('topbanner-upload');
			}
		});
		
		new ImageUpload(this.part, config);
		UI.resizeImage($('img', preview), { width: 360, height: 68 });
	},
	
	
	/**
	 * 招牌图片有变动时, 需要更新招牌板块的高度
	 * @param {string} custom 是否使用自定义招牌图片
	 */
	refreshBannerHeight: function(custom) {
		
		var self = this,
			heightInput = $('input.banner-height', this.part),
			path = $('input.path', this.part).val(),
			img = null;
			
		if (!custom) {
			this.mod.css('height', '');
			heightInput.val('');
			return;
		}
		
		if (!path) {
			return;
		}

		img = new Image();
		img.onload = function() {
			img.onload = null;	// 修复ie7下可能会触发多次onload事件 QC 24065
			var height = self.calcBannerHeight(this.height);
			self.mod.css('height', height);
			heightInput.val(height);
		};
		img.src = path;
	},
	
	/**
	 * 当图片高度 < minHeight时, 招牌高度为 minHeight
	 * 当图片高度 > maxHeight时, 招牌高度为maxHeight
	 * 其它情况, 招牌板块高度为图片高度
	 */
	calcBannerHeight: function(h) {
		var minHeight = 90,
			maxHeight = 200;
		return h < minHeight ? '' :	// 当图片高度 < minHeight时, 招牌高度为 minHeight
				h > maxHeight ? maxHeight + 'px' : // 当图片高度 > maxHeight时, 招牌高度为maxHeight
				h + 'px';	// 其它情况, 招牌板块高度为图片高度
	},
	
	/**
	 * 更新版块时, 需要根据情况调整招牌高度
	 */
	handleUpdateMod: function() {
		var self = this;
		this.mod.unbind('updatemod.refreshbanner');
		this.mod.bind('updatemod.refreshbanner', function(e, data) {
			self.refreshBannerHeight(data.isUseCustomTopBanner);
		});
	}
};
//~ TopbarPart 


/**
 * 公司LOGO和名称编辑部分
 */
Parts.NamePart = {
	
	init: function() {
		this.part = $('div.company-name-part', this.form);
		this.initNamePart();
		this.initImageUpload();
	},
		
	/**
	 * 初始化图片上传flash组件
	 */
	initImageUpload: function() {
		var self = this,
			logoPart = $('div.logo-part', this.part),
			preview = $('div.preview', logoPart);

		config = this.wrapUploadConfig({
			onUpload: function() {
				var img = $('img', logoPart);
				UI.resizeImage($('img', preview), 80);
				self.updateMod();
				self.dialog.node.trigger('logo-upload');
			},
			
			onRemove: function() {
				self.updateMod();
				self.dialog.node.trigger('logo-remove');
			}
		});
		
		new ImageUpload(logoPart, config);
		UI.resizeImage($('img', preview), 80);
	},
	
	/**
	 * 初始化招牌中英文编辑
	 */
	initNamePart: function() {
		var namePart = $('div.name-part', this.part);
		this.initColorPicker(namePart);
		this.initNamePartSetting(namePart);
		this.initNamePartUpdate(namePart);
		
	},
	
	/**
	 * 初始化颜色选取框
	 */
	initColorPicker: function(part) {
		var self = this,
			picker = $('a.widget-color-picker', part);
		UI.colorPicker(picker);
		picker.bind('select', function() {
			self.updateMod();
		});
	},
	
	/**
	 * 是否显示中英文名称交互逻辑
	 */
	initNamePartSetting: function(namePart) {
		var self = this,
			checks = $('input.show-zh,input.show-en', namePart),
			settings = $('a.setting', namePart);
		
		checks.click(function() {
			var setting = $(this).closest('dt').find('a.setting');
			setting[this.checked ? 'show' : 'hide']();
			setting.triggerHandler('click', true);
		});
		checks.triggerHandler('click');
		
		settings.click(function(e, hidden) {
			var dd = $(this).closest('dl').find('dd');
				hidden = hidden || dd.css('display') !== 'none';
			dd[hidden ? 'hide' : 'show']();
			
			return false;
		});
	},
	
	
	/**
	 * 处理公司名称样式变化事件
	 */
	initNamePartUpdate: function(namePart) {
		var self = this,
			handler = function() {
				self.updateMod();
			};
		$('select', namePart).change(handler);
		$(':checkbox', namePart).click(handler);
	}
	
	
};
//~ NamePart

//~ DefaultCompanyNameHandler


/**
 * 公司招牌Handler
 * 根据Tab当前选项, 把操作代理给相应Handler
 */
var CompanyNameHandler = {
	
	init: function(form, config, box) {
		this.box = box;
		this.bodies = $('div.app-edit-body', this.dialog.node);
		this.parts = $('div.mod>div', box);	
		this.loadLetFormHandler($.proxy(this, '_init'));
	},

	getFormConfig: function(box) {
		return DefaultCompanyNameHandler.getFormConfig(box);
	},

	/**
	 * 载入LetFormHandler
	 */
	loadLetFormHandler: function(callback) {
		if (WP.diy.form.LetFormHandler) {
			callback();
			return;
		}
		var url = 'http://style.china.alibaba.com/js/itbu/app/let-form-handler.js';
		$.ajax(url, {
			dataType: 'script',
			cache: false,
			success: callback
		});
	},

	_init: function() {
		this.initLetFormHandlerProxy();
		this.initTabs();
		this.initBodies();
	},

	initLetFormHandlerProxy: function() {
		this.LetFormHandlerProxy = $.extendIf({
			_getFormData: function() {
				var data = DefaultCompanyNameHandler._getFormData();
				$.extend(data, WP.diy.form.LetFormHandler._getFormData());
				return data;
			}
		}, WP.diy.form.LetFormHandler);
	},

	/**
	 * 初始化Tabs
	 * TOOD: Tabs的切换逻辑在LetFormHandler中完成了，所以这里不需要做
	 * 这个设计很烂，恶心~~
	 */
	initTabs: function() {
		var self = this,
			tabs = $('ul.app-edit-tabs li', this.dialog.node);
		
		tabs.click(function() {
			self.selectedIndex = $(this).index();	
		});	

		this.selectedIndex = tabs.filter('li.selected').index();
	},

	/**
	 * 初始化tab body
	 */
	initBodies: function() {
		var self = this;

		this.bodies.each(function(index, body) {
			var handler = self.getHandler(index),
				form = $('form', body),
				config = form.data('formConfig');

			handler.dialog = self.dialog;
			handler.init(form, config, self.box);
		});
	},

	/**
	 * 取得tab页相应FormHandler
	 */
	getHandler: function(index) {
		return index === 0 ? DefaultCompanyNameHandler : this.LetFormHandlerProxy;
	},
	
	validate: function() {
		return this._delegate('validate', arguments);
	},

	submit: function() {
		return this._delegate('submit', arguments); 	
	},

	cancel: function() {
		this._delegate('cancel', arguments);
		ModBox.reload(this.box);
	},

	_delegate: function(name, args) {
		var handler = this.getHandler(this.selectedIndex);
		return handler[name].apply(handler, args);
	}
};



WP.diy.form.CompanyNameHandler = CompanyNameHandler;


})(jQuery, Platform.winport);
//~
