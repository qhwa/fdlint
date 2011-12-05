/**
 * @fileoverview 即时验证
 * 
 * @author qijun.weiqj
 */
(function($, WP) {

/**
 * 即时验证失败时恢复上次内容
 * @param {selector|element} selector
 * @param {string|regexp|function|object{test: function}} type 验证器
 */
var InstantValidator = {

	validate: function(selector, type) {
		var self = this,
			v = this._getValidator(type);
		if (!v) {
			$.error('validator is not exist');
		}
		selector = $(selector);
		
		selector.bind('input propertychange', function() {
			var input = $(this),
				last = input.data('instant-validator-value') || '',
				value = input.val();
			
			if (!value || v.test(value)) {
				input.data('instant-validator-value', value);
			} else {
				// 延迟设置已防止再次触发input/propertychange, 以造成堆栈溢出
				setTimeout(function() {
					input.val(last);
				}, 50);
			}
		});
		
		selector.triggerHandler('input');
	},
	
	_getValidator: function(type) {
		var t = $.type(type);
		return t === 'string' ? this.types[type] :
			t === 'regexp' ? type :
			t === 'function' ? { test: type } : null;
	}
	
};

InstantValidator.types = {
	// 价格
	price: /^[\d]{0,9}(\.[\d]{0,2})?$/,
	// 分页
	pagenum: /^[1-9]\d*$/
};

WP.widget.InstantValidator = InstantValidator;

$.add('wp-instantvalidator');

})(jQuery, Platform.winport);
