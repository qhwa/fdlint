/**
 * @fileoverview 供应产品(自动)
 * 
 * @author qijun.weiqj
 */
(function($, WP) {
	
var Offers = WP.mod.unit.Offers;
	
/**
 * 侧边栏供应产品
 */
WP.ModContext.register('wp-auto-rec-offers-sub', function(div) {
	var imgs = $('div.image img', div);
	Offers.resizeImage(imgs, 64);
});


})(jQuery, Platform.winport);
//~
