/**
 * 提供一种方便创建类
 * @author qijun.weiqj
 */
(function($, WP) {


/**
 * 创建一个类
 * @param {object|function} parent  父类(可选)
 * @param {object} o 成员
 */
WP.Class = function(parent, o) {
	// 省略第一个参数
	if (!o) {
		o = parent;
		parent = null;
	}
	
	parent = typeof parent === 'function' ? 
			parent.prototype : parent;
		
	var klass = function() {
			this.parent = this.parent || parent;
			this.init && this.init.apply(this, arguments);
		},
		proto = parent ? $.extend({}, parent, o) : o;

	klass.prototype = proto;
	return klass;
};


})(jQuery, Platform.winport);
