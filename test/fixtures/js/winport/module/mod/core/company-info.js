/**
 * @fileoverview ¹«Ë¾½éÉÜ
 * 
 * @author qijun.weiqj
 */
(function($, WP) {
	
var UI = WP.UI;

var CompanyInfo = {
	
	init: function(div, config) {
		div = $(div);
		if (div.closest('div.grid-main').length) {
			var img = $('div.info-image img', div);
			UI.resizeImage(img, { 
				size: 300, 
				success: function() {
					div.trigger('afterinit');
				} 
			});
		}
	}
};

WP.ModContext.register('wp-company-info', CompanyInfo);	

})(jQuery, Platform.winport);
