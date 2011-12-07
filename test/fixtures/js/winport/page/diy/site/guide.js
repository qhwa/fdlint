/**
 * @fileoverview 旺铺DIY新手向导
 * 
 * @author qijun.weiqj
 */
(function($, WP) {
	
var Util = WP.Util,
	FloatTips = WP.widget.FloatTips;

	
var DiyGuide = {
		/**
	 * 初始化操作
	 * 1. 是否自动显示帮助向导
	 * 2. 处理帮助链接事件
	 */
	init: function() {
		this.autoShow();
		this.handleGuide();
	},
	
	/**
	 * 自动显示帮助向导
	 */
	autoShow: function() {
		var docCfg = $('#doc').data('doc-config');
		if (docCfg.showTutorialWizard) {
			window.open('http://view.china.alibaba.com/cms/itbu/20111101/guide.html');
		}
	},
	
	/**
	 * 处理帮助链接事件
	 * 1. 如果是首页, 则显示帮助向导
	 * 2. 非首页, 则跳转到首页显示帮助
	 */
	handleGuide: function() {
		var self = this,
			elm = $('#header ul.help-topics a.guide');
		elm.click(function(e) {
			e.preventDefault();
			window.open('http://view.china.alibaba.com/cms/itbu/20111101/guide.html');
		});
		
	}
};


WP.PageContext.register('~DiyGuide', DiyGuide);

	
})(jQuery, Platform.winport);
//~
