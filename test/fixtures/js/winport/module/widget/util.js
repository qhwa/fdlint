/**
 * @fileoverview 非界面相关的工具方法
 * 
 * @author qijun.weiqj
 */
(function($, WP) {

var Util = {
	isIE6: $.util.ua.ie6,
	isIE67: $.util.ua.ie67,
	
	/**
	 * 创建一个类
	 * @param {object|function} parent  父类(可选)
	 * @param {object} o 成员
	 */
	mkclass: function(parent, o) {
		return WP.Class(parent, o);
	},
	
	/**
	 * 同一name名称的操作覆盖执行
	 * @param {string} name 名称
	 * @param {function} action
	 * @param {number} delay
	 */
	schedule: function(name, action, delay) {
		this._schedule = this._schedule || {};
		this._schedule[name] && clearTimeout(this._schedule[name]);
		action && (this._schedule[name] = setTimeout(action, delay || 1000));
	},
	
	/**
	 * 拼接url
	 * @param {string} url
	 * @param {object} param
	 */
	formatUrl: function(url, param){
		if (!url || !param) {
			return url || '';
		}
		param = (typeof param === 'string') ? param : $.param(param);
		return param ? url + (url.indexOf('?') === -1 ? '?' : '&') + param : url;
	},
	
	/**
	 * 截取指定字节数
	 * @param {string} str
	 * @param {integer} len
	 * 
	 */
	cut: function(str, len) {
		if (Util.lenB(str) <= len) {
			return str;
		}
		
		var cl = 0;
        for(var i = 0, c = str.length; i < c; i++) {
			if (cl >= len) {
				return str.substr(0, i); 
			}
			var code = str.charCodeAt(i);
			cl += (code < 0 || code > 255) ? 2 : 1;
        }
        return '';
	},
	
	/**
	 * 返回字符串字节数
	 * @param {string} str
	 */
	lenB: function(str) {
		return str.replace(/[^\x00-\xff]/g,'**').length;
	},
	
	
	/**
	 * 简单模块分离包装
	 * 
	 * @param {string} name 名称 可选
	 * @param {object} o 模块对象
	 * @param {array} args
	 */
	initParts: function(name, o, args) {
		return new WP.Parts(name, o, args);
	},

	escape: function(str){
		return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#39;');
	},
	
	toCamelString: function(str) {
		return str.replace(/-(\w)/g, function(r, m) {
			return m.toUpperCase();
		});
	},

	evalScript: function(html) {
		var re = /<script\b[^>]*>([^<]*(?:(?!<\/script>)<[^<]*)*)<\/script>/i,
			match = re.exec(html || '');
		match && $.globalEval(match[1]);
	},

	delegate: function(o, fields) {
		var proxy = {};
		$.each($.makeArray(fields), function(index, field) {
			var v = o[field];
			proxy[field] = typeof v === 'function' ? $.proxy(v, o) : v;
		});
		return proxy;
	}
};
//~ Util

WP.Util = Util;
$.add('wp-util');


})(jQuery, Platform.winport);
//~
