/**
 * @fileoverview 特殊板块编辑逻辑
 * @author qijun.weiqj
 */
(function($, WP) {
	
	
var EditFilter = {
	init: function() {
		this.filterTopNav();
	},
	
	/**
	 * 编辑导横条时, 需要展开页面管理面板
	 */
	filterTopNav: function() {
		var panel = $('#header li.page-list-manage:first');
		
		$(window).bind('boxbeforeedit', function(e, data) {
			var mod = $('div.wp-top-nav', data.element);
			if (mod.length) {
				panel.click();
				return false
			}
		});
	}
}
//~ EditFilter


WP.PageContext.register('~EditFilter', EditFilter);

})(jQuery, Platform.winport)
