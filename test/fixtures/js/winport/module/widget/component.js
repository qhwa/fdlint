/**
 * 旺铺前后台公用逻辑
 * @author qijun.weiqj
 */
(function($, WP) {

var Component = {

	getDocConfig: function() {
		return this.docConfig = this.docConfig ||
				$('#doc').data('docConfig');
	},

	getContentConfig: function() {
		return this.contentConfig = this.contentConfig || 
				$('#content').data('contentConfig');
	},

	isEdit: function() {
		return this.getDocConfig().isEdit;
	},

	isHomePage: function() {
		return this.getDocConfig().isHomepage || this.getContentConfig().isHomepage;
	}	

};

WP.Component = Component;

})(jQuery, Platform.winport);
