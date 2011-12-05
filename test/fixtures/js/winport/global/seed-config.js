/**
 * @fileoverview 配置需要动态载入的模块
 *
 * @see lib/fdev-v4/core/gears.js, lib/fdev-v4/core/config.js
 *
 * @author qijun.weiqj
 */
(function ($) {

var mudules = {
	'wp-floatpanel': {
		js: ['widget/floatpanel']
	},

	'wp-inplaceeditor': {
		js: ['widget/inplaceeditor']
	},

	'wp-instantvalidator': {
		js: ['widget/instantvalidator']
	},

	'wp-dialog': {
		css: ['widget/dialog'],
		js: ['widget/dialog']
	},

	'wp-cssparser': {
		js: ['widget/cssparser']
	},

	'wp-htmleditor': {
		js: ['widget/htmleditor']
	},

	'wp-videoComponents':{
		css: ['widget/videoComponents'],
		js: ['widget/videoComponents']
	},

	/**
	 * Offer选择组件
	 */
	'wp-offer-chooser': {
		requires: ['wp-dialog'],
		css: ['widget/offer-chooser'],
		js: ['widget/offer-chooser']
	},

	'wp-vas-offer-chooser-data-provider': {
		js: ['mod/unit/vas-offer-chooser-data-provider']
	},

	/**
	 * 类目选择组件
	 */
	'wp-category-chooser': {
		requires: ['wp-dialog'],
		css: ['widget/category-chooser'],
		js: ['widget/category-chooser']
	},

	'wp-vas-category-chooser-data-provider': {
		js: ['mod/unit/vas-category-chooser-data-provider']
	},

	/**
	 * 类目Offer选择组件
	 */
	'wp-category-offer-chooser': {
		requires: ['wp-offer-chooser'],
		css: ['widget/category-chooser'],
		js: ['widget/category-chooser']
	},

	'wp-vas-category-offer-chooser-data-provider': {
		requires: ['wp-vas-offer-chooser-data-provider'],
		js: ['mod/unit/vas-category-chooser-data-provider']
	}
};


$.each(mudules, function(name, config) {
	var js = config.js,
		css = config.css || [];

	$.each(js, function(i) {
		js[i] = $.util.substitute('http://{0}/js/app/platform/winport/module/{name}-min.js', { name: this });
	});

	$.each(css, function(i) {
		css[i] = $.util.substitute('http://{0}/css/app/platform/winport/module/{name}.css', { name: this });
	});

	$.add(name, config);
});


/**
 * 图片银行
 */
$.add('wp-ibank', {
	css: ['http://style.china.alibaba.com/css/sys/ibank/ibank-min.css'],
	js: ['http://style.china.alibaba.com/js/sys/ibank/ibank-min.js'],
	ver: '1.0'
});



})(jQuery);
