/**
 * @fileoverview 提供表单通用操作
 * @author qijun.weiqj
 */
(function($, WP) {
	

var FormUtil = {
	/**
	 * 因为默认的serializeArray中checkbox未选中,将会没有数据
	 * 所以对此进行简单处理, 使其适应旺铺ajax提交
	 */
	getFormData: function(form) {
		form = $(form);
		var data = {},
			array = form.serializeArray();
		$.each(array, function() {
			data[this.name] = this.value;
		});
		
		$(':checkbox', form).each(function() {
			var name = this.name;
			name && (data[name] = !!data[name]);
		});
		
		return data;
	},
	
	/**
	 * 根据data渲染form
	 * @param {selector|element} form
	 * @param {object} data
	 */
	setFormData: function(form, data) {
		form = $(form);
		$.each(data, function(key) {
			var elm = form[key];
			if (!elm) {
				return;
			}
			if (elm.is(':checkbox,:radio')) {
				elm.attr('checked', !!this);
			} else {
				elm.val(this);
			}
		});
	},
	
	/**
	 * 显示表单域提示信息
	 */
	showMessage: function(elm, message, type, finder) {
		elm = $(elm);

		var advice = elm.data('message-advice'),
			lastType = null;
		if (!advice) {
			finder = finder || function(elm, type) {
				var ret = elm.closest('dd');
				if (!ret.length) {
					ret = elm.closest('div');
				}
				return ret.find('.message');
			};
			advice = finder(elm, type);
			elm.data('message-advice', advice);
		}
		
		lastType = advice.data('message-type');
		lastType && advice.removeClass(lastType);
		
		if (message) {
			type &&	advice.addClass(type).data('message-type', type);
			advice.html(message).show();
		} else {
			advice.hide();
		}
	}
	
};
//~ FormUtil

WP.widget.FormUtil = FormUtil;
$.add('wp-formutil');


})(jQuery, Platform.winport);
