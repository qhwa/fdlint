/**
 * @fileoverview 缩略模式
 * 
 * @author long.fanl
 */
(function($, WP){
	
var ViewMode = {
	
	init: function() {
		this.switcher = $('#view-mode-switch');
		
		WP.UI.positionFixed(this.switcher);
		this.handleToggle();
	},
	

	/**
	 * @Notice 整个#content里的内容会被重新载入, 所以不能保存里面任何节点的引用
	 */
	handleToggle: function() {
		var id = '#winport-content',
			sw = this.switcher;

		sw.toggle(function() {
			$(id).addClass('mini-mode');
        	sw.text('完整视图');
			window.scroll(0, 0);
		}, function() {
			$(id).removeClass('mini-mode');
			sw.text('缩略视图');
		});
	}
};

WP.PageContext.register('~ViewMode', ViewMode);

})(jQuery, Platform.winport);
