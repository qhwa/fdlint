/**
 * @fileoverview ÕÐÅÆ°å¿é
 * 
 * @author qijun.weiqj
 */
(function($, WP) {
	
var UI = WP.UI;


var CompanyName = {
	
	init: function(div) {
		var logo = $('div.logo img', div);	
		UI.resizeImage(logo, 80);
	}
	
};

WP.ModContext.register('wp-company-name', CompanyName);


})(jQuery, Platform.winport);
