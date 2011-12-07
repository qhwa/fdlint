/**
 * 旺铺diy后台我要提建议布点
 * @author qijun.weiqj
 */
(function($, WP) {

var AdviceEntry = {

	init: function() {
		var link = $('a.advice-entry', '#header');
		WP.UI.positionFixed(link);
	}

};


WP.PageContext.register('~AdviceEntry', AdviceEntry);

})(jQuery, Platform.winport);
