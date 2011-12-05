/**
 * DIY前后台都需要的特殊逻辑
 * @author qijun.weiqj
 */
(function($, WP) {

var SpecialLogic = {
	
	init: function() {
		$.use('ui-flash', $.proxy(this, 'checkFlashVersion'));
	},

	checkFlashVersion: function() {
		if ($.util.flash.hasVersion(10) || !WP.Component.isHomePage()) {
			return;
		}
		$.use('wp-dialog', function() {
			WP.widget.Dialog.open({
				header: '提醒',
				content: '<div class="d-msg" style="padding-bottom: 20px;"><span class="info">您没有安装Flash或版本过低，可能会导致部<br />分功能展示异常，请升级您的Flash。<a href="http://get.adobe.com/cn/flashplayer/" target="_blank">立即升级</a></span></div>',
				buttons: [
					{ 'class': 'd-confirm', value: '我知道了' }	
				]
			});
		});
	}

};


WP.PageContext.register('~SpecialLogic', SpecialLogic);


})(jQuery, Platform.winport);
