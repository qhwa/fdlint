/**
 * DIY后台信息提示
 * 
 * @author qijun.weiqj
 */
(function($, WP) {
	
WP.diy.Msg = {
	
	info: function(msg, options) {
		this.show(msg, 'info',{
			interval: 2000
		});
	},
	
	error: function(msg, options) {
		this.show(msg, 'error',{
			interval: 3000
		});
	},
	
	warn: function(msg, options) {
		this.show(msg, 'warn',{
			interval: 3000
		});
	},
	
	show: function(msg, type, options) {
		var elm = this._elm(),
			span = $('<span>').addClass(type).text(msg);
		options = options || {};
		elm.empty().append(span);
		options.stop && elm.stop(true, true);
		elm.fadeIn().delay(options.interval || 2000).fadeOut('fast', function() {
			$(this).empty();
		});
	},
	
	_elm: function() {
		this.__elm = this.__elm || $('#header div.diy-message');
		return this.__elm;
	}
	
};
	
})(jQuery, Platform.winport);


