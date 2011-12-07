/**
 * @fileoverview 旺铺DIY页入口
 */
(function($, WP) {

var Msg = WP.diy.Msg;

var Diy = {
	init: function() {
		this.logDiyChanged();
		this.ajaxSetup();
	},
	
	logDiyChanged: function() {
		$(window).bind('diychanged', function(e, data) {
			$.log('diychanged: ' + data.type);
		});
	},
	
	ajaxSetup: function() {
		var fn = function() {
			$.ajaxSetup({
				error: function(){
					Msg.error('网络繁忙，请刷新后重试');
				}
			});
		};
		setTimeout(fn, 2000);
	}
	
};


WP.PageContext.register('~Diy', Diy);

})(jQuery, Platform.winport);
//~
