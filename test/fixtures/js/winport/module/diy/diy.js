/**
 * @fileoverview DIY页工具方法
 * 
 * @author long.fanl
 */
(function($, WP) {

var Msg = WP.diy.Msg;

var Diy = {
	
	/**
	 * authAjax处理使用xhr进行POST请求
	 * 统一对success的data进行判断，为空则显示网络繁忙
	 * 解决IE下xhr对302响应走到success逻辑的问题
	 * @param {string} url
	 * @param {object} options
	 */
	authAjax: function(url, options){
		var self = this, 
			success = options.success,
			msg = '网络繁忙，请刷新后重试';
		
		options.error = options.error || function() {
			Msg.warn(msg);
		};	
		
		options.success = function(data){
			if(!data){
				options.error();
				return;
			}
			success && success.apply(this, arguments);
		};
		
		$.ajax(url, options);
	}
};

WP.diy.Diy = Diy;

})(jQuery, Platform.winport);
//~
